CREATE TABLE IF NOT EXISTS pdfinvoices (
    id                      BIGSERIAL PRIMARY KEY,

    -- ---- Identifiers -------------------------------------------------------
    invoice_number          TEXT        NOT NULL,
    invoice_type            TEXT        NOT NULL DEFAULT 'invoice',
    purchase_order_number   TEXT,

    -- ---- Dates -------------------------------------------------------------
    issue_date              DATE,
    due_date                DATE,

    -- ---- Currency ----------------------------------------------------------
    currency                CHAR(3),

    -- ---- Seller (flattened for querying) -----------------------------------
    seller_name             TEXT,
    seller_tax_id           TEXT,
    seller_email            TEXT,
    seller_phone            TEXT,
    seller_city             TEXT,
    seller_state            TEXT,
    seller_postal_code      TEXT,
    seller_country_code     CHAR(2),

    -- ---- Buyer -------------------------------------------------------------
    buyer_name              TEXT,
    buyer_tax_id            TEXT,
    buyer_email             TEXT,
    buyer_city              TEXT,
    buyer_state             TEXT,
    buyer_postal_code       TEXT,
    buyer_country_code      CHAR(2),

    -- ---- Totals ------------------------------------------------------------
    subtotal                NUMERIC(18,2),
    total_charges           NUMERIC(18,2),
    total_tax               NUMERIC(18,2),
    grand_total             NUMERIC(18,2),
    prior_balance           NUMERIC(18,2),
    amount_paid             NUMERIC(18,2),
    total_due               NUMERIC(18,2),

    -- ---- Nested structures -------------------------------------------------
    line_items              JSONB       NOT NULL DEFAULT '[]'::jsonb,
    charges                 JSONB       NOT NULL DEFAULT '[]'::jsonb,

    -- ---- Provenance --------------------------------------------------------
    raw_json                JSONB       NOT NULL,   -- full LLM response
    raw_text                TEXT,                   -- LlamaParse output
    source_filename         TEXT,
    model                   TEXT,

    -- ---- Housekeeping ------------------------------------------------------
    line_item_count         INTEGER GENERATED ALWAYS AS (jsonb_array_length(line_items)) STORED,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pdfinvoices_line_items_is_array CHECK (jsonb_typeof(line_items) = 'array'),
    CONSTRAINT pdfinvoices_charges_is_array    CHECK (jsonb_typeof(charges) = 'array')
);

CREATE UNIQUE INDEX IF NOT EXISTS pdfinvoices_seller_number_uq
    ON pdfinvoices (seller_name, invoice_number);

CREATE INDEX IF NOT EXISTS pdfinvoices_issue_date_idx   ON pdfinvoices (issue_date DESC);
CREATE INDEX IF NOT EXISTS pdfinvoices_due_date_idx     ON pdfinvoices (due_date);
CREATE INDEX IF NOT EXISTS pdfinvoices_buyer_name_idx   ON pdfinvoices (buyer_name);
CREATE INDEX IF NOT EXISTS pdfinvoices_raw_json_gin     ON pdfinvoices USING GIN (raw_json jsonb_path_ops);
CREATE INDEX IF NOT EXISTS pdfinvoices_line_items_gin   ON pdfinvoices USING GIN (line_items jsonb_path_ops);

-- Keep updated_at honest.
CREATE OR REPLACE FUNCTION set_pdfinvoices_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pdfinvoices_set_updated_at ON pdfinvoices;
CREATE TRIGGER pdfinvoices_set_updated_at
    BEFORE UPDATE ON pdfinvoices
    FOR EACH ROW EXECUTE FUNCTION set_pdfinvoices_updated_at();