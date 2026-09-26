

-- ============================================================
-- BASE DE DATOS: ALMACÉN EL HUECO — EVIDENCIA 1
-- Ficha: 3489088 | 23 Tablas según modelo entregado
-- ============================================================
DROP DATABASE IF EXISTS almacen;
CREATE DATABASE almacen
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE almacen;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- MATRIZ DE TRAZABILIDAD RF → TABLAS
-- ============================================================
-- RF-01 Roles y permisos                    -> ROL, Permisos, ROLES_has_Permisos
-- RF-02 Gestión de usuarios                 -> Usuario
-- RF-03 Gestión de clientes                 -> Clientes, Tipo_Cliente
-- RF-04 Gestión de categorías               -> Categoria
-- RF-05 Gestión de productos                -> Producto
-- RF-06 Gestión de inventario               -> Inventario, Movimiento_Inventario
-- RF-07 Gestión de proveedores              -> Proveedores
-- RF-08 Registro de compras                 -> Compras, Detalle_Compra
-- RF-09 Actualización de inventario compra  -> Inventario, Movimiento_Inventario
-- RF-10 Registro de ventas                  -> Ventas, Detalle_Venta
-- RF-11 Descuento de inventario por venta   -> Inventario, Movimiento_Inventario
-- RF-12 Métodos de pago                     -> Metodos_de_pago
-- RF-13 Créditos                             -> Credito
-- RF-14 Abonos                               -> Abonos
-- RF-15 Historial de pagos                  -> Abonos, Metodos_de_pago
-- RF-16 Pedidos                              -> Pedidos, Detalle_pedido
-- RF-17 Plan separe                         -> Pedidos
-- RF-18 Devoluciones                        -> Devoluciones, Detalle_devoluciones
-- RF-19 Reingreso por devolución            -> Inventario, Movimiento_Inventario
-- RF-20 Consulta de productos               -> Producto, Categoria, Inventario
-- RF-21 Consulta de ventas                  -> Ventas, Detalle_Venta
-- RF-22 Consulta de compras                 -> Compras, Detalle_Compra
-- RF-23 Consulta de clientes                -> Clientes, Tipo_Cliente
-- RF-24 Consulta de proveedores             -> Proveedores
-- RF-25 Alertas de stock mínimo             -> Inventario, Producto
-- RF-26 Anulación de ventas                 -> Ventas (estado: ANULADA)
-- RF-27 Anulación/cancelación de compras    -> Compras
-- RF-28 Anulación de créditos/abonos        -> Credito, Abonos
-- RF-29 Comprobantes y pedidos              -> Ventas, Pedidos
-- RF-30 Protección de datos personales      -> Usuario (autorizacion_datos + hash) — Ley 1581
-- RF-31 Trazabilidad de operaciones         -> Tablas con fecha_creacion, fecha_actualizacion, Usuario_id
-- Cobertura: 31/31 RF = 100% ✅
-- ============================================================

-- ============================================================
-- 1. TABLA ROL
-- ============================================================
CREATE TABLE ROL (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB COMMENT='RF-01: Perfiles de usuario';

-- ============================================================
-- 2. TABLA Permisos
-- ============================================================
CREATE TABLE Permisos (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_permiso_nombre (nombre)
) ENGINE=InnoDB COMMENT='RF-01: Acciones del sistema';

-- ============================================================
-- 3. TABLA Usuario
-- ============================================================
CREATE TABLE Usuario (
    id INT NOT NULL AUTO_INCREMENT,
    tipo_documento VARCHAR(45) NOT NULL,
    documento VARCHAR(45) NOT NULL,
    primer_nombre VARCHAR(45) NOT NULL,
    segundo_nombre VARCHAR(45) NULL,
    primer_apellido VARCHAR(45) NOT NULL,
    segundo_apellido VARCHAR(45) NULL,
    estado TINYINT NOT NULL DEFAULT 1 COMMENT '1=Activo, 0=Inactivo — Borrado lógico',
    direccion VARCHAR(100) NOT NULL,
    telefono VARCHAR(45) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    contrasenia VARCHAR(255) NOT NULL COMMENT 'Hash SHA2 — RNF Seguridad',
    autorizacion_datos TINYINT NOT NULL DEFAULT 0 COMMENT 'Ley 1581: Consentimiento',
    fecha_autorizacion DATETIME NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    ROL_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_usuario_documento (documento),
    UNIQUE KEY uk_usuario_correo (correo),
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (ROL_id)
        REFERENCES ROL(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-02: Personal del sistema';

-- ============================================================
-- 4. TABLA Tipo_Cliente
-- ============================================================
CREATE TABLE Tipo_Cliente (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    porcentaje DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tipo_cliente_nombre (nombre),
    CONSTRAINT chk_tipo_cliente_porcentaje CHECK (porcentaje BETWEEN 0 AND 100)
) ENGINE=InnoDB COMMENT='RF-03: Categoría de clientes';

-- ============================================================
-- 5. TABLA Clientes
-- ============================================================
CREATE TABLE Clientes (
    id INT NOT NULL AUTO_INCREMENT,
    tipo_documento VARCHAR(45) NOT NULL,
    documento VARCHAR(45) NOT NULL,
    primer_nombre VARCHAR(45) NOT NULL,
    segundo_nombre VARCHAR(45) NULL,
    primer_apellido VARCHAR(45) NULL,
    segundo_apellido VARCHAR(45) NULL,
    telefono VARCHAR(45) NOT NULL,
    correo VARCHAR(100) NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    estado_cliente TINYINT NOT NULL DEFAULT 1 COMMENT 'Borrado lógico',
    Tipo_Cliente_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cliente_documento (documento),
    CONSTRAINT fk_cliente_tipo
        FOREIGN KEY (Tipo_Cliente_id)
        REFERENCES Tipo_Cliente(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-03: Registro de clientes';

-- ============================================================
-- 6. TABLA Categoria
-- ============================================================
CREATE TABLE Categoria (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(100) NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    estado TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uk_categoria_nombre (nombre)
) ENGINE=InnoDB COMMENT='RF-04: Clasificación de productos';

-- ============================================================
-- 7. TABLA Impuestos
-- ============================================================
CREATE TABLE Impuestos (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    porcentaje DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_impuesto_nombre (nombre),
    CONSTRAINT chk_impuesto_porcentaje CHECK (porcentaje BETWEEN 0 AND 100)
) ENGINE=InnoDB COMMENT='RF-05: Tarifas impositivas';

-- ============================================================
-- 8. TABLA Producto
-- ============================================================
CREATE TABLE Producto (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    Categoria_id INT NOT NULL,
    Impuesto_id INT NOT NULL,
    estado TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (Categoria_id)
        REFERENCES Categoria(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_producto_impuesto
        FOREIGN KEY (Impuesto_id)
        REFERENCES Impuestos(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_producto_precio_compra CHECK (precio_compra >= 0),
    CONSTRAINT chk_producto_precio_venta CHECK (precio_venta >= 0)
) ENGINE=InnoDB COMMENT='RF-05: Productos comercializados';

-- ============================================================
-- 9. TABLA Inventario
-- ============================================================
CREATE TABLE Inventario (
    id INT NOT NULL AUTO_INCREMENT,
    cantidad INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL,
    stock_maximo INT NULL,
    fecha_actualizacion DATE NULL,
    Producto_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_inventario_producto (Producto_id),
    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (Producto_id)
        REFERENCES Producto(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_inventario_cantidad CHECK (cantidad >= 0),
    CONSTRAINT chk_inventario_minimo CHECK (stock_minimo >= 0),
    CONSTRAINT chk_inventario_maximo CHECK (stock_maximo IS NULL OR stock_maximo >= stock_minimo)
) ENGINE=InnoDB COMMENT='RF-06: Control de existencias';

-- ============================================================
-- 10. TABLA Proveedores
-- ============================================================
CREATE TABLE Proveedores (
    id INT NOT NULL AUTO_INCREMENT,
    tipo_documento VARCHAR(45) NOT NULL,
    documento VARCHAR(45) NOT NULL,
    primer_nombre VARCHAR(45) NOT NULL,
    segundo_nombre VARCHAR(45) NULL,
    primer_apellido VARCHAR(45) NULL,
    segundo_apellido VARCHAR(45) NULL,
    nit_proveedor VARCHAR(45) NULL,
    telefono VARCHAR(45) NOT NULL,
    correo_electronico VARCHAR(100) NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_proveedor_documento (documento),
    UNIQUE KEY uk_proveedor_nit (nit_proveedor)
) ENGINE=InnoDB COMMENT='RF-07: Proveedores de mercancía';

-- ============================================================
-- 11. TABLA Compras
-- ============================================================
CREATE TABLE Compras (
    id INT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(45) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    observaciones VARCHAR(100) NULL,
    fecha_creacion DATETIME NULL,
    fecha_actualizacion DATETIME NULL,
    Proveedores_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_compra_codigo (codigo),
    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY (Proveedores_id)
        REFERENCES Proveedores(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-08: Compras registradas';

-- ============================================================
-- 12. TABLA Detalle_Compra — CORREGIDO: Producto_id
-- ============================================================
CREATE TABLE Detalle_Compra (
    id INT NOT NULL AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    fecha_compra DATETIME NOT NULL,
    Compras_id INT NOT NULL,
    Producto_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_detalle_compra_compra
        FOREIGN KEY (Compras_id)
        REFERENCES Compras(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_compra_producto
        FOREIGN KEY (Producto_id)
        REFERENCES Producto(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-08: Líneas por compra';

-- ============================================================
-- 13. TABLA Ventas
-- ============================================================
CREATE TABLE Ventas (
    id INT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(45) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    pago DECIMAL(10,2) NULL,
    saldo_pendiente DECIMAL(10,2) NULL,
    fecha_creacion DATETIME NULL,
    fecha_actualizacion DATETIME NULL,
    tipo_transaccion VARCHAR(45) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' COMMENT 'ACTIVA/ANULADA — RF-26',
    Clientes_id INT NOT NULL,
    Metodos_de_pago_id INT NOT NULL,
    Credito_id INT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_venta_codigo (codigo),
    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (Clientes_id)
        REFERENCES Clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_venta_valores CHECK (
        valor_total >= 0 AND
        (pago IS NULL OR pago >= 0) AND
        (saldo_pendiente IS NULL OR saldo_pendiente >= 0)
    )
) ENGINE=InnoDB COMMENT='RF-10: Ventas y anulaciones';

-- ============================================================
-- 14. TABLA Detalle_Venta — CORREGIDO: Producto_id
-- ============================================================
CREATE TABLE Detalle_Venta (
    id INT NOT NULL AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    Ventas_id INT NOT NULL,
    Producto_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_detalle_venta_venta
        FOREIGN KEY (Ventas_id)
        REFERENCES Ventas(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_venta_producto
        FOREIGN KEY (Producto_id)
        REFERENCES Producto(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-10: Líneas por venta';

-- ============================================================
-- 15. TABLA Credito
-- ============================================================
CREATE TABLE Credito (
    id INT NOT NULL AUTO_INCREMENT,
    cupo_maximo DECIMAL(10,2) NOT NULL,
    cuotas INT NOT NULL,
    saldo_pendiente DECIMAL(10,2) NOT NULL,
    fecha_creacion DATE NULL,
    fecha_actualizacion DATE NULL,
    estado_credito VARCHAR(45) NULL,
    Clientes_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_credito_cliente
        FOREIGN KEY (Clientes_id)
        REFERENCES Clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_credito_valores CHECK (
        cupo_maximo >= 0 AND
        cuotas > 0 AND
        saldo_pendiente >= 0
    )
) ENGINE=InnoDB COMMENT='RF-13: Créditos otorgados';

-- ============================================================
-- 16. TABLA Metodos_de_pago
-- ============================================================
CREATE TABLE Metodos_de_pago (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_metodo_pago_nombre (nombre)
) ENGINE=InnoDB COMMENT='RF-12: Formas de pago';

-- ============================================================
-- 17. TABLA Abonos
-- ============================================================
CREATE TABLE Abonos (
    id INT NOT NULL AUTO_INCREMENT,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATETIME NOT NULL,
    observaciones VARCHAR(100) NULL,
    Credito_id INT NOT NULL,
    Metodos_de_pago_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_abono_credito
        FOREIGN KEY (Credito_id)
        REFERENCES Credito(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_abono_metodo
        FOREIGN KEY (Metodos_de_pago_id)
        REFERENCES Metodos_de_pago(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-14: Pagos a créditos';

-- ============================================================
-- 18. TABLA Pedidos
-- ============================================================
CREATE TABLE Pedidos (
    id INT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(45) NOT NULL,
    fecha_pedido DATE NOT NULL,
    observaciones VARCHAR(100) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE',
    fecha_vencimiento DATETIME NULL,
    fecha_creacion DATE NOT NULL,
    fecha_actualizacion DATE NULL,
    Clientes_id INT NOT NULL,
    Usuario_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_pedido_codigo (codigo),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (Clientes_id)
        REFERENCES Clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (Usuario_id)
        REFERENCES Usuario(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-16/RF-17: Pedidos y plan separe';

-- ============================================================
-- 19. TABLA Detalle_pedido — CORREGIDO: Producto_id
-- ============================================================
CREATE TABLE Detalle_pedido (
    id INT NOT NULL AUTO_INCREMENT,
    Producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    Pedidos_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_detalle_pedido_pedido
        FOREIGN KEY (Pedidos_id)
        REFERENCES Pedidos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_pedido_producto
        FOREIGN KEY (Producto_id)
        REFERENCES Producto(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-16: Productos reservados';

-- ============================================================
-- 20. TABLA Devoluciones
-- ============================================================
CREATE TABLE Devoluciones (
    id INT NOT NULL AUTO_INCREMENT,
    fecha DATE NOT NULL,
    motivo VARCHAR(100) NULL,
    Ventas_id INT NOT NULL,
    Clientes_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_devolucion_venta
        FOREIGN KEY (Ventas_id)
        REFERENCES Ventas(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_devolucion_cliente
        FOREIGN KEY (Clientes_id)
        REFERENCES Clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-18: Productos devueltos';

-- ============================================================
-- 21. TABLA Detalle_devoluciones — CORREGIDO: Producto_id
-- ============================================================
CREATE TABLE Detalle_devoluciones (
    id INT NOT NULL AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    Devoluciones_id INT NOT NULL,
    Producto_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_detalle_devolucion_devolucion
        FOREIGN KEY (Devoluciones_id)
        REFERENCES Devoluciones(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_devolucion_producto
        FOREIGN KEY (Producto_id)
        REFERENCES Producto(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-18: Líneas devueltas';

-- ============================================================
-- 22. TABLA Movimiento_Inventario
-- ============================================================
CREATE TABLE Movimiento_Inventario (
    id INT NOT NULL AUTO_INCREMENT,
    tipo_movimiento VARCHAR(45) NOT NULL COMMENT 'ENTRADA/SALIDA/REINGRESO',
    cantidad INT NOT NULL,
    motivo VARCHAR(100) NULL,
    fecha DATETIME NOT NULL,
    Inventario_id INT NOT NULL,
    Usuario_id INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_movimiento_inventario
        FOREIGN KEY (Inventario_id)
        REFERENCES Inventario(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_movimiento_usuario
        FOREIGN KEY (Usuario_id)
        REFERENCES Usuario(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-06/RF-31: Historial de cambios — Bitácora';

-- ============================================================
-- 23. TABLA ROLES_has_Permisos
-- ============================================================
CREATE TABLE ROLES_has_Permisos (
    ROL_id INT NOT NULL,
    Permisos_id INT NOT NULL,
    PRIMARY KEY (ROL_id, Permisos_id),
    CONSTRAINT fk_roles_permisos_rol
        FOREIGN KEY (ROL_id)
        REFERENCES ROL(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_roles_permisos_permiso
        FOREIGN KEY (Permisos_id)
        REFERENCES Permisos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='RF-01: Asignación de permisos';

-- ============================================================
-- RELACIONES ADICIONALES
-- ============================================================
ALTER TABLE Ventas
    ADD CONSTRAINT fk_venta_metodo_pago
        FOREIGN KEY (Metodos_de_pago_id)
        REFERENCES Metodos_de_pago(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    ADD CONSTRAINT fk_venta_credito
        FOREIGN KEY (Credito_id)
        REFERENCES Credito(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

-- ============================================================
-- DATOS INICIALES
-- ============================================================
-- 1. ROLES
INSERT INTO ROL (nombre, fecha_creacion) VALUES
('Administrador', '2026-09-01'),
('Vendedor', '2026-09-01');

-- 2. PERMISOS
INSERT INTO Permisos (nombre, fecha_creacion) VALUES
('Gestionar Roles', '2026-09-01'),
('Gestionar Usuarios', '2026-09-01'),
('Gestionar Productos', '2026-09-01'),
('Gestionar Compras', '2026-09-01'),
('Gestionar Ventas', '2026-09-01'),
('Gestionar Inventario', '2026-09-01');

-- 3. ROLES Y PERMISOS
INSERT INTO ROLES_has_Permisos (ROL_id, Permisos_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
(2,3),(2,5),(2,6);

-- 4. USUARIOS
INSERT INTO Usuario (
    tipo_documento, documento, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido, estado, direccion, telefono,
    correo, contrasenia, autorizacion_datos, fecha_autorizacion,
    fecha_creacion, fecha_actualizacion, ROL_id
) VALUES
('Cédula','434567890','Clara Cristina Benavidez',NULL,'El Hueco',NULL,
    1,'Cra 54 # 50-99 piso 3, Medellín','3008993467',' clara.benavidez12@gmail.com',
    SHA2('admin123',256),1,'2026-09-01 08:00:00','2026-09-01','2026-09-01',1),
('Cédula','987654321','María',NULL,'Vendedora',NULL,
    1,'Calle 50 #10-20, Medellín','3109876543','vendedor@elhueco.com',
    SHA2('vendedor123',256),1,'2026-09-01 08:00:00','2026-09-01','2026-09-01',2);

-- 5. TIPOS DE CLIENTE
INSERT INTO Tipo_Cliente (nombre, descripcion, porcentaje) VALUES
('Mayorista','Compra al por mayor - margen 20%',20.00),
('Al Detal','Compra al detal - margen 25%',25.00);

-- 6. CLIENTES
INSERT INTO Clientes (
    tipo_documento, documento, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido, telefono, correo,
    fecha_creacion, fecha_actualizacion, estado_cliente, Tipo_Cliente_id
) VALUES
('NIT','890123456','Tienda Ropa Bella',NULL,NULL,NULL,
    '3201112233','contacto@ropabella.com','2026-09-01','2026-09-01',1,1),
('Cédula','1001234567','Ever','Julio',NULL,NULL,
    '3154445566','ever.julio@email.com','2026-09-01','2026-09-01',1,2),
('Cédula','1009876543','Estefania','Muñoz',NULL,NULL,
    '3007778899','estefania@email.com','2026-09-01','2026-09-01',1,2);

-- 7. CATEGORIAS
INSERT INTO Categoria (nombre, descripcion, fecha_creacion, fecha_actualizacion, estado) VALUES
('Camisetas','Prendas superiores de algodón','2026-09-01','2026-09-01',1),
('Jeans','Pantalones en mezclilla','2026-09-01','2026-09-01',1),
('Vestidos','Vestidos para dama','2026-09-01','2026-09-01',1),
('Chaquetas','Prendas exteriores y abrigos','2026-09-01','2026-09-01',1),
('Pantalones','Pantalones de todo tipo','2026-09-01','2026-09-01',1);

-- 8. IMPUESTOS
INSERT INTO Impuestos (nombre, porcentaje, descripcion) VALUES
('IVA',19.00,'Impuesto al valor agregado');

-- 9. PRODUCTOS
INSERT INTO Producto (
    nombre, precio_compra, precio_venta, fecha_creacion,
    fecha_actualizacion, Categoria_id, Impuesto_id, estado
) VALUES
('Camiseta Básica Negra M',20000.00,25000.00,'2026-09-01','2026-09-01',1,1,1),
('Camiseta Básica Blanca L',20000.00,25000.00,'2026-09-01','2026-09-01',1,1,1),
('Jean Clásico Azul 30',55000.00,68750.00,'2026-09-01','2026-09-01',2,1,1),
('Vestido Casual Estampado M',40000.00,50000.00,'2026-09-01','2026-09-01',3,1,1),
('Chaqueta Ligera Gris L',60000.00,75000.00,'2026-09-01','2026-09-01',4,1,1);

-- 10. INVENTARIO
INSERT INTO Inventario (
    cantidad, stock_minimo, stock_maximo, fecha_actualizacion, Producto_id
) VALUES
(50,5,100,'2026-09-01',1),
(30,5,100,'2026-09-01',2),
(25,5,100,'2026-09-01',3),
(15,3,50,'2026-09-01',4),
(10,3,50,'2026-09-01',5);

-- 11. METODOS DE PAGO
INSERT INTO Metodos_de_pago (nombre, descripcion) VALUES
('Efectivo','Pago en dinero en efectivo'),
('Transferencia','Transferencia bancaria'),
('Tarjeta Débito','Pago con tarjeta débito'),
('Tarjeta Crédito','Pago con tarjeta crédito'),
('Crédito','Pago a plazo - genera cartera');

-- 12. PROVEEDORES
INSERT INTO Proveedores (
    tipo_documento, documento, primer_nombre, segundo_nombre,
    primer_apellido, segundo_apellido, nit_proveedor, telefono,
    correo_electronico, fecha_creacion, fecha_actualizacion
) VALUES
('NIT','812345678','Textiles del Sur',NULL,NULL,NULL,
    '812345678','6041234567','ventas@textilesdelsur.com','2026-09-01','2026-09-01'),
('NIT','876543210','Confecciones Modernas',NULL,NULL,NULL,
    '876543210','6049876543','pedidos@confeccionesmodernas.com','2026-09-01','2026-09-01');

-- 13. COMPRAS
INSERT INTO Compras (
    codigo, valor_total, observaciones, fecha_creacion,
    fecha_actualizacion, Proveedores_id
) VALUES
('COMP-001',2975000.00,'Compra de mercancía','2026-09-01 10:00:00','2026-09-01 10:00:00',1),
('COMP-002',600000.00,'Compra de chaquetas','2026-09-05 14:30:00','2026-09-05 14:30:00',2);

-- 14. DETALLE DE COMPRAS
INSERT INTO Detalle_Compra (
    cantidad, precio_unitario, precio_total, fecha_compra,
    Compras_id, Producto_id
) VALUES
(50,20000.00,1000000.00,'2026-09-01 10:00:00',1,1),
(30,20000.00,600000.00,'2026-09-01 10:00:00',1,2),
(25,55000.00,1375000.00,'2026-09-01 10:00:00',1,3),
(10,60000.00,600000.00,'2026-09-05 14:30:00',2,5);

-- 15. VENTAS
INSERT INTO Ventas (
    codigo, valor_total, pago, saldo_pendiente, fecha_creacion,
    fecha_actualizacion, tipo_transaccion, estado, Clientes_id,
    Metodos_de_pago_id, Credito_id
) VALUES
('VT-001',118750.00,118750.00,0.00,'2026-09-08 11:15:00',
    '2026-09-08 11:15:00','Contado','ACTIVA',2,1,NULL),
('VT-002',1140000.00,500000.00,640000.00,'2026-09-09 15:00:00',
    '2026-09-09 15:00:00','Crédito','ACTIVA',1,5,1);

-- 16. DETALLE DE VENTAS
INSERT INTO Detalle_Venta (
    cantidad, precio_unitario, precio_total, Ventas_id, Producto_id
) VALUES
(2,25000.00,50000.00,1,1),
(1,68750.00,68750.00,1,3),
(20,24000.00,480000.00,2,1),
(10,66000.00,660000.00,2,3);

-- 17. CREDITOS
INSERT INTO Credito (
    cupo_maximo, cuotas, saldo_pendiente, fecha_creacion,
    fecha_actualizacion, estado_credito, Clientes_id
) VALUES
(1250000.00,12,640000.00,'2026-09-09','2026-09-09','Vigente',1);

-- 18. ABONOS
INSERT INTO Abonos (
    monto, fecha, observaciones, Credito_id, Metodos_de_pago_id
) VALUES
(500000.00,'2026-09-10 10:00:00','Abono inicial',1,2);

-- 19. PEDIDOS
INSERT INTO Pedidos (
    codigo, fecha_pedido, observaciones, estado, fecha_vencimiento,
    fecha_creacion, fecha_actualizacion, Clientes_id, Usuario_id
) VALUES
('PED-001','2026-09-10','Prenda reservada','PENDIENTE',
    '2026-09-11 23:59:59','2026-09-10','2026-09-10',3,2);

-- 20. DETALLE PEDIDO
INSERT INTO Detalle_pedido (
    Producto_id, cantidad, precio_unitario, precio_total, Pedidos_id
) VALUES
(4,2,50000.00,100000.00,1);

-- 21. DEVOLUCIONES
INSERT INTO Devoluciones (fecha, motivo, Ventas_id, Clientes_id) VALUES
('2026-09-10','Prenda con defecto de fabricación',1,2);

-- 22. DETALLE DEVOLUCIONES
INSERT INTO Detalle_devoluciones (
    cantidad, precio_unitario, precio_total, Devoluciones_id, Producto_id
) VALUES
(1,25000.00,25000.00,1,1);

-- 23. MOVIMIENTOS DE INVENTARIO
INSERT INTO Movimiento_Inventario (
    tipo_movimiento, cantidad, motivo, fecha, Inventario_id, Usuario_id
) VALUES
('ENTRADA',50,'Compra #1 a Textiles del Sur','2026-09-01 10:00:00',1,1),
('ENTRADA',30,'Compra #1 a Textiles del Sur','2026-09-01 10:00:00',2,1),
('ENTRADA',25,'Compra #1 a Textiles del Sur','2026-09-01 10:00:00',3,1),
('ENTRADA',10,'Compra #2 a Confecciones Modernas','2026-09-05 14:30:00',5,1),
('SALIDA',2,'Venta #1 - Cliente Ever Julio','2026-09-08 11:15:00',1,2),
('SALIDA',1,'Venta #1 - Cliente Ever Julio','2026-09-08 11:15:00',3,2),
('SALIDA',20,'Venta #2 - Crédito Tienda Ropa Bella','2026-09-09 15:00:00',1,2),
('SALIDA',10,'Venta #2 - Crédito Tienda Ropa Bella','2026-09-09 15:00:00',3,2),
('REINGRESO',1,'Devolución - Venta #1','2026-09-10 10:00:00',1,2);

-- ACTUALIZAR STOCK
UPDATE Inventario SET cantidad = 4 WHERE id = 1;
UPDATE Inventario SET cantidad = 30 WHERE id = 2;
UPDATE Inventario SET cantidad = 14 WHERE id = 3;
UPDATE Inventario SET cantidad = 2 WHERE id = 4;
UPDATE Inventario SET cantidad = 1 WHERE id = 5;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- CATÁLOGO CRUD COMPLETO POR TABLA — C9
-- ============================================================
-- Estructura: SELECT PK → SELECT lista → JOIN → UPDATE PK → Borrado lógico/DELETE
-- ============================================================

-- ROL | RF-01
SELECT * FROM ROL WHERE id = 1;
SELECT id, nombre FROM ROL ORDER BY nombre;
SELECT r.nombre AS rol, p.nombre AS permiso FROM ROL r JOIN ROLES_has_Permisos rhp ON r.id = rhp.ROL_id JOIN Permisos p ON rhp.Permisos_id = p.id;
UPDATE ROL SET fecha_actualizacion = CURDATE() WHERE id = 1;
DELETE FROM ROL WHERE id = 999;

-- Permisos | RF-01
SELECT * FROM Permisos WHERE id = 1;
SELECT * FROM Permisos ORDER BY nombre;
SELECT p.nombre AS permiso, r.nombre AS rol FROM Permisos p JOIN ROLES_has_Permisos rhp ON p.id = rhp.Permisos_id JOIN ROL r ON rhp.ROL_id = r.id;
UPDATE Permisos SET fecha_actualizacion = CURDATE() WHERE id = 1;
DELETE FROM Permisos WHERE id = 999;

-- Usuario | RF-02 — Borrado lógico
SELECT * FROM Usuario WHERE id = 1;
SELECT id, primer_nombre, correo, estado FROM Usuario ORDER BY primer_nombre;
SELECT u.*, r.nombre AS rol_nombre FROM Usuario u JOIN ROL r ON u.ROL_id = r.id;
UPDATE Usuario SET telefono = '3000000000', fecha_actualizacion = CURDATE() WHERE id = 1;
UPDATE Usuario SET estado = 0 WHERE id = 999;

-- Tipo_Cliente | RF-03
SELECT * FROM Tipo_Cliente WHERE id = 1;
SELECT * FROM Tipo_Cliente ORDER BY nombre;
SELECT tc.*, COUNT(c.id) AS cantidad_clientes FROM Tipo_Cliente tc LEFT JOIN Clientes c ON tc.id = c.Tipo_Cliente_id GROUP BY tc.id;
UPDATE Tipo_Cliente SET porcentaje = 22.00 WHERE id = 1;
DELETE FROM Tipo_Cliente WHERE id = 999;

-- Clientes | RF-03 — Borrado lógico
SELECT * FROM Clientes WHERE id = 1;
SELECT id, primer_nombre, telefono, estado_cliente FROM Clientes ORDER BY primer_nombre;
SELECT c.*, tc.nombre AS tipo_cliente FROM Clientes c JOIN Tipo_Cliente tc ON c.Tipo_Cliente_id = tc.id;
UPDATE Clientes SET telefono = '3200000000' WHERE id = 1;
UPDATE Clientes SET estado_cliente = 0 WHERE id = 999;

-- Categoria | RF-04
SELECT * FROM Categoria WHERE id = 1;
SELECT id, nombre, estado FROM Categoria ORDER BY nombre;
SELECT c.*, COUNT(p.id) AS total_productos FROM Categoria c LEFT JOIN Producto p ON c.id = p.Categoria_id GROUP BY c.id;
UPDATE Categoria SET descripcion = 'Prendas de algodón' WHERE id = 1;
DELETE FROM Categoria WHERE id = 999;

-- Impuestos | RF-05
SELECT * FROM Impuestos WHERE id = 1;
SELECT * FROM Impuestos ORDER BY nombre;
SELECT i.*, COUNT(p.id) AS productos_asociados FROM Impuestos i LEFT JOIN Producto p ON i.id = p.Impuesto_id GROUP BY i.id;
UPDATE Impuestos SET descripcion = 'IVA Colombia' WHERE id = 1;
DELETE FROM Impuestos WHERE id = 999;

-- Producto | RF-05
SELECT * FROM Producto WHERE id = 1;
SELECT id, nombre, precio_venta, estado FROM Producto ORDER BY nombre;
SELECT p.*, c.nombre AS categoria, i.cantidad AS stock FROM Producto p JOIN Categoria c ON p.Categoria_id = c.id JOIN Inventario i ON p.id = i.Producto_id;
UPDATE Producto SET precio_venta = 26000.00 WHERE id = 1;
UPDATE Producto SET estado = 0 WHERE id = 999;

-- Inventario | RF-06
SELECT * FROM Inventario WHERE id = 1;
SELECT p.nombre, i.cantidad, i.stock_minimo FROM Inventario i JOIN Producto p ON i.Producto_id = p.id;
SELECT p.nombre, i.* FROM Inventario i JOIN Producto p ON i.Producto_id = p.id WHERE i.cantidad < i.stock_minimo;
UPDATE Inventario SET cantidad = 5 WHERE id = 1;
DELETE FROM Inventario WHERE id = 999;

-- Proveedores | RF-07
SELECT * FROM Proveedores WHERE id = 1;
SELECT id, primer_nombre, telefono FROM Proveedores ORDER BY primer_nombre;
SELECT pr.*, COUNT(c.id) AS compras FROM Proveedores pr LEFT JOIN Compras c ON pr.id = c.Proveedores_id GROUP BY pr.id;
UPDATE Proveedores SET telefono = '6040000000' WHERE id = 1;
DELETE FROM Proveedores WHERE id = 999;

-- Compras | RF-08
SELECT * FROM Compras WHERE id = 1;
SELECT codigo, valor_total, fecha_creacion FROM Compras ORDER BY fecha_creacion DESC;
SELECT c.*, p.primer_nombre AS proveedor FROM Compras c JOIN Proveedores p ON c.Proveedores_id = p.id;
UPDATE Compras SET observaciones = 'Compra confirmada' WHERE id = 1;
DELETE FROM Compras WHERE id = 999;

-- Detalle_Compra | RF-08
SELECT * FROM Detalle_Compra WHERE id = 1;
SELECT Compras_id, Producto_id, cantidad, precio_total FROM Detalle_Compra;
SELECT dc.*, c.codigo, p.nombre AS producto FROM Detalle_Compra dc JOIN Compras c ON dc.Compras_id = c.id JOIN Producto p ON dc.Producto_id = p.id;
UPDATE Detalle_Compra SET precio_unitario = 21000.00 WHERE id = 1;
DELETE FROM Detalle_Compra WHERE id = 999;

-- Ventas | RF-10 — Anulación = borrado lógico
SELECT * FROM Ventas WHERE id = 1;
SELECT codigo, valor_total, estado FROM Ventas ORDER BY fecha_creacion DESC;
SELECT v.*, c.primer_nombre AS cliente, m.nombre AS metodo_pago FROM Ventas v JOIN Clientes c ON v.Clientes_id = c.id JOIN Metodos_de_pago m ON v.Metodos_de_pago_id = m.id;
UPDATE Ventas SET estado = 'ANULADA' WHERE id = 999; -- RF-26 Anulación

-- Detalle_Venta | RF-10
SELECT * FROM Detalle_Venta WHERE id = 1;
SELECT Ventas_id, Producto_id, cantidad, precio_total FROM Detalle_Venta;
SELECT dv.*, v.codigo, p.nombre AS producto FROM Detalle_Venta dv JOIN Ventas v ON dv.Ventas_id = v.id JOIN Producto p ON dv.Producto_id = p.id;
UPDATE Detalle_Venta SET precio_unitario = 26000.00 WHERE id = 1;
DELETE FROM Detalle_Venta WHERE id = 999;

-- Credito | RF-13
SELECT * FROM Credito WHERE id = 1;
SELECT id, cupo_maximo, saldo_pendiente, estado_credito FROM Credito;
SELECT cr.*, c.primer_nombre AS cliente FROM Credito cr JOIN Clientes c ON cr.Clientes_id = c.id;
UPDATE Credito SET saldo_pendiente = 0 WHERE id = 1;
DELETE FROM Credito WHERE id = 999;

-- Metodos_de_pago | RF-12
SELECT * FROM Metodos_de_pago WHERE id = 1;
SELECT * FROM Metodos_de_pago ORDER BY nombre;
SELECT mp.*, COUNT(v.id) AS ventas_usaron FROM Metodos_de_pago mp LEFT JOIN Ventas v ON mp.id = v.Metodos_de_p