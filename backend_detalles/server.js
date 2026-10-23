const express = require('express');
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

// Carpeta donde se guardan las imágenes subidas
const carpetaImagenes = path.join(__dirname, 'imagenes');
if (!fs.existsSync(carpetaImagenes)) {
    fs.mkdirSync(carpetaImagenes);
}
// Configuración de multer: guarda el archivo con un nombre único
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, carpetaImagenes),
    filename: (req, file, cb) => {
        const nombreUnico = Date.now() + '-' + file.originalname;
        cb(null, nombreUnico);
    }
});
const upload = multer({ storage });
// Servir la carpeta de imágenes de forma estática
app.use('/imagenes', express.static(carpetaImagenes));

// Middleware fallback: si una imagen no existe físicamente, envía un placeholder
app.get('/imagenes/:filename', (req, res) => {
    const fileEntry = path.join(carpetaImagenes, req.params.filename);
    fs.access(fileEntry, fs.constants.F_OK, (errDefault) => {
        if (errDefault) {
            return res.sendFile(path.join(carpetaImagenes, 'placeholder.png'));
        }
        return res.sendFile(fileEntry);
    });
});



// ============================================
// LOGIN Y REGISTRO (tablas: usuarios + roles)
// ============================================
app.post('/api/login', async (req, res) => {
    try {
        const { correo, contrasena } = req.body;
        const query = `
            SELECT u.id_usuario, u.nombre, u.correo, r.nombre_rol AS rol
            FROM usuarios u
            JOIN roles r ON u.id_rol = r.id_rol
            WHERE u.correo = $1 AND u.contrasena = $2;
        `;
        const resultado = await pool.query(query, [correo, contrasena]);

        if (resultado.rows.length === 0) {
            return res.status(401).json({ status: 'error', message: 'Correo o contraseña incorrectos' });
        }
        res.json({ status: 'ok', usuario: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/register', async (req, res) => {
    try {
        const { nombre, correo, contrasena, id_rol } = req.body;
        const query = `
            INSERT INTO usuarios (nombre, correo, contrasena, id_rol)
            VALUES ($1, $2, $3, $4)
            RETURNING id_usuario, nombre, correo;
        `;
        const resultado = await pool.query(query, [nombre, correo, contrasena, id_rol]);
        res.status(201).json({ status: 'ok', usuario: resultado.rows[0] });
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ status: 'error', message: 'Ese correo ya está registrado' });
        }
        res.status(500).json({ error: err.message });
    }
});
// Configuración de conexión a PostgreSQL — base de datos: detalles_sammy
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'detalles_sammy',
    password: 'root',
    port: 5432,
});
// ============================================
// PRODUCTOS (tabla: productos)
// ============================================

app.get('/api/productos', async (req, res) => {
    try {
        const resultado = await pool.query('SELECT * FROM productos ORDER BY id_producto DESC;');
        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/productos', upload.single('imagen'), async (req, res) => {
    try {
        const { nombre, precio, categoria, descripcion, disponible, id_usuario } = req.body;
        const rutaFoto = req.file
            ? `http://localhost:3000/imagenes/${req.file.filename}`
            : 'http://localhost:3000/imagenes/placeholder.png';

        const query = `
            INSERT INTO productos (nombre, precio, categoria, descripcion, foto, disponible, id_usuario)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *;`;
        const resultado = await pool.query(query, [
            nombre,
            parseFloat(precio),
            categoria,
            descripcion,
            rutaFoto,
            disponible === undefined ? true : disponible,
            id_usuario
        ]);
        res.status(201).json({ status: 'success', producto: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
app.put('/api/productos/:id', upload.single('imagen'), async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, precio, categoria, descripcion, disponible } = req.body;
        let query, values;

        if (req.file) {
            const rutaFoto = `http://localhost:3000/imagenes/${req.file.filename}`;
            query = `
                UPDATE productos
                SET nombre = $1, precio = $2, categoria = $3, descripcion = $4, foto = $5, disponible = $6
                WHERE id_producto = $7
                RETURNING *; `;
            values = [nombre, parseFloat(precio), categoria, descripcion, rutaFoto, disponible, id];
        } else {
            query = `
                UPDATE productos
                SET nombre = $1, precio = $2, categoria = $3, descripcion = $4, disponible = $5
                WHERE id_producto = $6
                RETURNING *;   `;
            values = [nombre, parseFloat(precio), categoria, descripcion, disponible, id];
        }
        const resultado = await pool.query(query, values);
        res.json({ status: 'success', producto: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
app.delete('/api/productos/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM productos WHERE id_producto = $1;', [id]);
        res.json({ status: 'success', message: 'Producto eliminado de la base de datos' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
// ============================================
// ROLES (tabla: roles)
// Columnas: id_rol, nombre_rol
// El GET regresa un solo registro (por id), no una lista completa.
// ============================================
app.get('/api/roles/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const resultado = await pool.query(
            'SELECT * FROM roles WHERE id_rol = $1 LIMIT 1;',
            [id] );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Rol no encontrado' });
        }
        res.json({ status: 'success', rol: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
app.post('/api/roles', async (req, res) => {
    try {
        const { nombre_rol } = req.body;
        const query = `
            INSERT INTO roles (nombre_rol)
            VALUES ($1)
            RETURNING *; `;
        const resultado = await pool.query(query, [nombre_rol]);
        res.status(201).json({ status: 'success', rol: resultado.rows[0] });
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ status: 'error', message: 'Ese rol ya existe' });
        }
        res.status(500).json({ error: err.message });
    }
});
app.put('/api/roles/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre_rol } = req.body;
        const query = `
            UPDATE roles
            SET nombre_rol = $1
            WHERE id_rol = $2
            RETURNING *; `;
        const resultado = await pool.query(query, [nombre_rol, id]);
        if (resultado.rows.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Rol no encontrado' });
        }
        res.json({ status: 'success', rol: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
app.delete('/api/roles/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const resultado = await pool.query(
            'DELETE FROM roles WHERE id_rol = $1 RETURNING *;',
            [id]
        );
        if (resultado.rows.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Rol no encontrado' });
        }
        res.json({ status: 'success', message: 'Rol eliminado de la base de datos' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});