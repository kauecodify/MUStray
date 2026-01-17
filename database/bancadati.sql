-- bd principal
CREATE DATABASE strategic_trade_monitoring;
USE strategic_trade_monitoring;

-- armazenar taxas de câmbio do BCE
CREATE TABLE ecb_exchange_rates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    base_currency VARCHAR(3) NOT NULL,
    target_currency VARCHAR(3) NOT NULL,
    rate DECIMAL(18,6) NOT NULL,
    date DATE NOT NULL,
    volume BIGINT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'European Central Bank',
    UNIQUE KEY unique_rate (base_currency, target_currency, date)
);

-- armazenar taxas de câmbio do BCB
CREATE TABLE bcb_exchange_rates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    currency VARCHAR(3) NOT NULL,
    bid DECIMAL(18,6) NOT NULL,
    ask DECIMAL(18,6) NOT NULL,
    date DATE NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'Banco Central do Brasil',
    UNIQUE KEY unique_rate (currency, date)
);

-- dados de inflação do BCB
CREATE TABLE bcb_inflation_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date VARCHAR(7) NOT NULL, -- formato 'Mes/Ano'
    monthly_value DECIMAL(5,2) NOT NULL,
    accumulated_value DECIMAL(5,2) NOT NULL,
    period_type ENUM('monthly', 'quarterly', 'yearly') DEFAULT 'monthly',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'Banco Central do Brasil',
    UNIQUE KEY unique_inflation (date, period_type)
);

--dados comerciais do Banco Mundial
CREATE TABLE world_bank_trade_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    indicator_code VARCHAR(20) NOT NULL,
    indicator_name VARCHAR(200) NOT NULL,
    value DECIMAL(20,2),
    year INT NOT NULL,
    unit VARCHAR(50),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'Banco Mundial',
    UNIQUE KEY unique_trade_data (country_code, indicator_code, year)
);

-- dados econômicos do Banco Mundial
CREATE TABLE world_bank_economic_indicators (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    indicator_code VARCHAR(20) NOT NULL,
    value DECIMAL(20,2),
    year INT NOT NULL,
    unit VARCHAR(50),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'Banco Mundial',
    UNIQUE KEY unique_econ_data (country_code, indicator_code, year)
);

-- índices de risco da OCDE
CREATE TABLE ocde_risk_indices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quarter VARCHAR(6) NOT NULL, -- formato 'Q1/26'
    sector VARCHAR(50) NOT NULL,
    risk_value DECIMAL(5,1) NOT NULL,
    period_type ENUM('monthly', 'quarterly', 'yearly') DEFAULT 'quarterly',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'OCDE',
    UNIQUE KEY unique_risk_index (quarter, sector, period_type)
);

-- projeções econômicas da OCDE
CREATE TABLE ocde_economic_projections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year INT NOT NULL,
    indicator VARCHAR(50) NOT NULL,
    value VARCHAR(20) NOT NULL,
    confidence_interval VARCHAR(20),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'OCDE',
    UNIQUE KEY unique_projection (year, indicator)
);

-- contratos aprovados do SISCOMEX
CREATE TABLE siscomex_approved_contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contract_id VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    exporting_country VARCHAR(100) NOT NULL,
    importing_country VARCHAR(100) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    total_value DECIMAL(20,2) NOT NULL,
    delivery_start DATE,
    delivery_end DATE,
    risk_score DECIMAL(5,1),
    status VARCHAR(20) DEFAULT 'approved',
    approval_date DATE,
    expiration_date DATE,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'SISCOMEX'
);

-- contratos pendentes do SISCOMEX
CREATE TABLE siscomex_pending_contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contract_id VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    exporting_country VARCHAR(100) NOT NULL,
    importing_country VARCHAR(100) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    total_value DECIMAL(20,2) NOT NULL,
    delivery_date DATE,
    risk_score DECIMAL(5,1),
    strategic_value DECIMAL(5,1),
    approval_stage VARCHAR(100),
    responsible_analyst VARCHAR(100),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'SISCOMEX'
);

-- empresas europeias
CREATE TABLE european_companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    company_id VARCHAR(50) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    registration_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    risk_rating DECIMAL(5,1),
    compliance_score DECIMAL(5,1),
    last_audit_date DATE,
    authorized_markets JSON,
    regulatory_approvals JSON,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'European Trade Register',
    UNIQUE KEY unique_company (country_code, company_id)
);

-- acordos comerciais europeus
CREATE TABLE european_trade_agreements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    agreement_id VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL,
    effective_date DATE,
    expiration_date DATE,
    parties JSON,
    verified BOOLEAN DEFAULT false,
    compliance_status VARCHAR(20),
    last_audit_date DATE,
    regulatory_framework TEXT,
    authorized_products JSON,
    trade_limits JSON,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) DEFAULT 'European Trade Register'
);

-- cache da API (melhor performance)
CREATE TABLE api_cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cache_key VARCHAR(255) NOT NULL UNIQUE,
    data JSON NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    source_api VARCHAR(100)
);

-- logs da API
CREATE TABLE api_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(100) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    metadata JSON,
    status ENUM('success', 'error') DEFAULT 'success',
    error_message TEXT,
    stack_trace TEXT,
    INDEX idx_timestamp (timestamp),
    INDEX idx_source_endpoint (source, endpoint)
);

-- configurações do sistema
CREATE TABLE system_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value VARCHAR(255) NOT NULL,
    description TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- inserir configurações iniciais
INSERT INTO system_config (config_key, config_value, description) VALUES
('API_TIMEOUT', '30000', 'Tempo limite para requisições da API em milissegundos'),
('CACHE_DURATION', '300000', 'Duração do cache em milissegundos (5 minutos)'),
('RETRY_ATTEMPTS', '3', 'Número de tentativas de retry para requisições falhas'),
('MAX_CONCURRENT_REQUESTS', '5', 'Número máximo de requisições simultâneas'),
('ENVIRONMENT', 'production', 'Ambiente de execução: development, staging, production');
