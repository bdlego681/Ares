-- ============================================================================
-- Ares E-Commerce & Control Plane Database Initialization
-- Target: SQL Server Express / LocalDB / Azure SQL
-- Product: Ares (Tactical & Performance Computing Hardware)
-- Tables: Products, SiteConfig, Orders, OrderItems
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- ----------------------------------------------------------------------------
-- Drop Foreign Keys and Tables in Dependency Order
-- ----------------------------------------------------------------------------
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.SiteConfig', 'U') IS NOT NULL DROP TABLE dbo.SiteConfig;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;

-- ----------------------------------------------------------------------------
-- 1. Products Table
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Products (
    Id INT IDENTITY(1,1) NOT NULL,
    Slug NVARCHAR(100) NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Subtitle NVARCHAR(255) NULL,
    Description NVARCHAR(MAX) NULL,
    Price DECIMAL(10, 2) NOT NULL,
    CompareAtPrice DECIMAL(10, 2) NULL,
    Category NVARCHAR(50) NOT NULL,
    Stock INT NOT NULL CONSTRAINT DF_Products_Stock DEFAULT (0),
    IsLimitedDrop BIT NOT NULL CONSTRAINT DF_Products_IsLimitedDrop DEFAULT (0),
    IsFeatured BIT NOT NULL CONSTRAINT DF_Products_IsFeatured DEFAULT (0),
    Badge NVARCHAR(50) NULL,
    ImageUrl NVARCHAR(500) NULL,
    SpecsJson NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Products_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (Id ASC),
    CONSTRAINT UQ_Products_Slug UNIQUE NONCLUSTERED (Slug ASC),
    CONSTRAINT CHK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Products_Stock CHECK (Stock >= 0)
);

CREATE NONCLUSTERED INDEX IX_Products_Category ON dbo.Products(Category ASC);
CREATE NONCLUSTERED INDEX IX_Products_IsFeatured ON dbo.Products(IsFeatured ASC);
CREATE NONCLUSTERED INDEX IX_Products_IsLimitedDrop ON dbo.Products(IsLimitedDrop ASC);

-- ----------------------------------------------------------------------------
-- 2. SiteConfig Table (Live Storefront Configuration & Banner Control)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.SiteConfig (
    Id INT IDENTITY(1,1) NOT NULL,
    ConfigKey NVARCHAR(100) NOT NULL,
    ConfigValue NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(255) NULL,
    UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_SiteConfig_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_SiteConfig PRIMARY KEY CLUSTERED (Id ASC),
    CONSTRAINT UQ_SiteConfig_Key UNIQUE NONCLUSTERED (ConfigKey ASC)
);

-- ----------------------------------------------------------------------------
-- 3. Orders Table
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Orders (
    Id INT IDENTITY(1,1) NOT NULL,
    OrderNumber NVARCHAR(50) NOT NULL,
    CustomerName NVARCHAR(200) NOT NULL,
    CustomerEmail NVARCHAR(200) NOT NULL,
    ShippingAddress NVARCHAR(300) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    PostalCode NVARCHAR(20) NOT NULL,
    Country NVARCHAR(50) NOT NULL CONSTRAINT DF_Orders_Country DEFAULT ('United States'),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('Pending'),
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Orders_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id ASC),
    CONSTRAINT UQ_Orders_OrderNumber UNIQUE NONCLUSTERED (OrderNumber ASC),
    CONSTRAINT CHK_Orders_Status CHECK (Status IN ('Pending', 'Packed', 'Shipped', 'Canceled')),
    CONSTRAINT CHK_Orders_TotalAmount CHECK (TotalAmount >= 0)
);

CREATE NONCLUSTERED INDEX IX_Orders_Status ON dbo.Orders(Status ASC);
CREATE NONCLUSTERED INDEX IX_Orders_CreatedAt ON dbo.Orders(CreatedAt DESC);

-- ----------------------------------------------------------------------------
-- 4. OrderItems Table
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.OrderItems (
    Id INT IDENTITY(1,1) NOT NULL,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_OrderItems_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_OrderItems PRIMARY KEY CLUSTERED (Id ASC),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id),
    CONSTRAINT CHK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_OrderItems_Prices CHECK (UnitPrice >= 0 AND TotalPrice >= 0)
);

CREATE NONCLUSTERED INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId ASC);
CREATE NONCLUSTERED INDEX IX_OrderItems_ProductId ON dbo.OrderItems(ProductId ASC);

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Seed: Products (Evergreen High-Stock + Limited Drop Low-Stock)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.Products (
    Slug, Name, Subtitle, Description, Price, CompareAtPrice, Category, Stock, IsLimitedDrop, IsFeatured, Badge, ImageUrl, SpecsJson
) VALUES
-- 1. Low-Stock Limited Drop Item (Only 3 Units Allocated)
(
    'ares-chronos-mk1',
    'Ares Chronos Mk.1 Tactical Field Unit',
    'Limited Production Grade 5 Titanium Compute Node',
    'The pinnacle of Ares hardware architecture. Precision CNC-milled from solid aerospace-grade titanium with an integrated sapphire crystal telemetry HUD. Features a dedicated offline cryptographic security enclave, dual high-bandwidth hardware buses, and hermetically sealed mil-grade thermal dissipation. Limited run strictly allocated to 3 units for this cycle.',
    1499.00,
    1799.00,
    'Special Ops',
    3,              -- Low-stock limited drop (3 units)
    1,              -- IsLimitedDrop = true
    1,              -- IsFeatured = true
    'LIMITED DROP',
    'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80',
    '["Aerospace Grade 5 Titanium Monocoque", "Sapphire Glass Status Telemetry Display", "Hardware Cryptographic Key Vault", "Run 01 // Limited to 50 Global Units", "Hermetic IP68 Submersion Rating"]'
),
-- 2. High-Stock Evergreen Workstation
(
    'ares-sentinel-x1',
    'Ares Sentinel X1 Tactical Workstation',
    'Edge compute chassis with redundant power routing and vapor chamber',
    'Purpose-built for zero-downtime command ops, real-time spatial calculations, and uninterrupted field computation. Reinforced unibody internal roll cage prevents board flex under extreme g-forces. Features dual high-throughput PCIe Gen 5 routing and redundant dual DC power inputs.',
    2850.00,
    NULL,
    'Workstations',
    9999,           -- High-stock evergreen
    0,              -- IsLimitedDrop = false
    1,              -- IsFeatured = true
    'EVERGREEN',
    'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=900&q=80',
    '["Dual 10GbE SFP+ Fiber Uplinks", "MIL-STD-810H Shock & Vibration Certified", "Vapor Chamber Silent Liquid Array", "Hot-Swappable Dual DC Power Rail"]'
),
-- 3. High-Stock Evergreen Peripheral: Hall-Effect Keypad
(
    'ares-apex-65',
    'Ares Apex-65 Magnetic Keypad',
    '65% CNC anodized aluminum chassis with rapid-trigger hall effect switches',
    'Machined from a monolithic billet of 6061-T6 aluminum with integrated acoustic dampening silicone layers. Hall effect magnetic switches register actuation down to 0.1mm with instant reset response for maximum physical input velocity.',
    240.00,
    NULL,
    'Peripherals',
    9999,           -- High-stock evergreen
    0,              -- IsLimitedDrop = false
    1,              -- IsFeatured = true
    'EVERGREEN',
    'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=900&q=80',
    '["0.1mm - 4.0mm Dynamic Rapid Trigger", "8000Hz Ultra-Fast Polling Rate", "Monolithic 6061-T6 Aluminum Frame", "PBT Double-Shot Custom Ares Keycaps"]'
),
-- 4. High-Stock Evergreen Peripheral: Precision Sensor Mouse
(
    'ares-vector-mouse',
    'Ares Vector Ultra-Light Mouse',
    'Carbon composite exoskeleton with 32,000 DPI Phase-4 optical sensor',
    'Engineered for surgical pointer control. The ultra-rigid honeycomb carbon exoskeleton drops total mass to 48 grams without structural compromise. Pure virgin-grade PTFE feet glide effortlessly across any command surface.',
    160.00,
    195.00,
    'Peripherals',
    9999,           -- High-stock evergreen
    0,              -- IsLimitedDrop = false
    0,              -- IsFeatured = false
    'SALE',
    'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=900&q=80',
    '["48g Ultra-Lightweight Carbon Matrix", "32,000 DPI Phase-4 Optical Engine", "Zero-Debounce Optical Microswitches", "90-Hour High-Speed Wireless Run Time"]'
),
-- 5. High-Stock Evergreen Accessory: EMP & RF Shielding Sleeve
(
    'ares-aegis-sleeve',
    'Ares Aegis EMP & RF Shielding Sleeve',
    'Multi-layer ballistic nylon with signal attenuation Faraday lining',
    'Military-grade radio frequency isolation barrier. Prevents remote signal detection, GPS telemetry extraction, and protects internal circuitry from high-power electromagnetic pulse events.',
    85.00,
    NULL,
    'Accessories',
    9999,           -- High-stock evergreen
    0,              -- IsLimitedDrop = false
    0,              -- IsFeatured = false
    'EVERGREEN',
    'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=900&q=80',
    '[">100dB RF Attenuation (10MHz - 10GHz)", "1000D Ballistic Cordura Shell", "Double Magnetic Fold-Over Hermetic Seal", "Shields Laptops up to 16 Inches"]'
),
-- 6. High-Stock Evergreen Audio: Planar Magnetic Headset
(
    'ares-specter-audio',
    'Ares Specter Planar Magnetic Monitor',
    'Closed-back tactical communication headset with spatial awareness DSP',
    'High-resolution planar magnetic drivers deliver pristine spatial resolution from 10Hz to 45kHz. Integrated dual noise-canceling beamforming microphones filter out 38dB of ambient background noise for crystal clear comms.',
    420.00,
    NULL,
    'Audio',
    9999,           -- High-stock evergreen
    0,              -- IsLimitedDrop = false
    0,              -- IsFeatured = false
    'EVERGREEN',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
    '["50mm Ultra-Thin Planar Diaphragm", "Hybrid ANC with Tactical Pass-Through", "Detachable Broadcast Supercardioid Boom Mic", "Dual Wireless 2.4GHz + Low-Latency Bluetooth"]'
);

-- ----------------------------------------------------------------------------
-- Seed: SiteConfig
-- ----------------------------------------------------------------------------
INSERT INTO dbo.SiteConfig (ConfigKey, ConfigValue, Description) VALUES
(
    'hero_eyebrow',
    'ARES INDUSTRIAL SYSTEMS // PROTOCOL 2026',
    'Eyebrow badge text in storefront hero banner'
),
(
    'hero_title',
    'TACTICAL ARCHITECTURE. UNCOMPROMISED PRECISION.',
    'Main headline text on storefront homepage'
),
(
    'hero_subtitle',
    'Engineered for mission-critical operations, extreme environments, and zero-compromise professionals. Browse our evergreen inventory or secure the limited Chronos drop.',
    'Subtitle paragraph below the hero headline'
),
(
    'hero_cta_text',
    'EXPLORE CATALOG',
    'Primary CTA button label in homepage hero'
),
(
    'hero_cta_link',
    '/catalog',
    'Route destination for the homepage hero CTA button'
),
(
    'announcement_bar',
    'LIMITED DROP ALLOCATION: ARES CHRONOS MK.1 IS LIVE // ONLY 3 UNITS AVAILABLE GLOBALLY',
    'Top notification banner content across all storefront pages'
),
(
    'announcement_enabled',
    'true',
    'Controls whether the announcement bar is visible (true/false)'
),
(
    'featured_drop_slug',
    'ares-chronos-mk1',
    'Slug of the active limited-drop product highlighted on the home view'
),
(
    'store_status',
    'OPERATIONAL',
    'General operational status indicator shown in admin and footer'
);

-- ----------------------------------------------------------------------------
-- Seed: Orders & OrderItems (Realistic Operational Sample Records)
-- ----------------------------------------------------------------------------
INSERT INTO dbo.Orders (
    OrderNumber, CustomerName, CustomerEmail, ShippingAddress, City, State, PostalCode, Country, TotalAmount, Status, CreatedAt
) VALUES
(
    'ARES-2026-1001',
    'Major Elena Vance',
    'elena.vance@orbitalops.net',
    '742 Falcon Crest Way, Suite 400',
    'Seattle',
    'WA',
    '98101',
    'United States',
    2850.00,
    'Shipped',
    DATEADD(day, -3, SYSUTCDATETIME())
),
(
    'ARES-2026-1002',
    'Marcus Mercer',
    'mercer@apexgrid.tech',
    '100 Tech Ridge Parkway, Bldg 3',
    'Austin',
    'TX',
    '78759',
    'United States',
    400.00,
    'Packed',
    DATEADD(day, -1, SYSUTCDATETIME())
),
(
    'ARES-2026-1003',
    'Commander Sarah Connor',
    's.connor@skydefense.org',
    '505 Desert Highway Terminal',
    'Flagstaff',
    'AZ',
    '86001',
    'United States',
    1499.00,
    'Pending',
    SYSUTCDATETIME()
);

-- Order Items for Order 1: Ares Sentinel X1
INSERT INTO dbo.OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, TotalPrice)
SELECT o.Id, p.Id, p.Name, p.Price, 1, p.Price
FROM dbo.Orders o
JOIN dbo.Products p ON p.Slug = 'ares-sentinel-x1'
WHERE o.OrderNumber = 'ARES-2026-1001';

-- Order Items for Order 2: Apex-65 Keypad ($240) + Vector Mouse ($160)
INSERT INTO dbo.OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, TotalPrice)
SELECT o.Id, p.Id, p.Name, 240.00, 1, 240.00
FROM dbo.Orders o
JOIN dbo.Products p ON p.Slug = 'ares-apex-65'
WHERE o.OrderNumber = 'ARES-2026-1002';

INSERT INTO dbo.OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, TotalPrice)
SELECT o.Id, p.Id, p.Name, 160.00, 1, 160.00
FROM dbo.Orders o
JOIN dbo.Products p ON p.Slug = 'ares-vector-mouse'
WHERE o.OrderNumber = 'ARES-2026-1002';

-- Order Items for Order 3: Ares Chronos Mk.1 Limited Drop ($1499)
INSERT INTO dbo.OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, TotalPrice)
SELECT o.Id, p.Id, p.Name, p.Price, 1, p.Price
FROM dbo.Orders o
JOIN dbo.Products p ON p.Slug = 'ares-chronos-mk1'
WHERE o.OrderNumber = 'ARES-2026-1003';
