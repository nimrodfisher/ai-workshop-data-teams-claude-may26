-- QA: Uniqueness — support_tickets primary key
SELECT COUNT(*) AS total, COUNT(DISTINCT id) AS unique_tickets FROM support_tickets;

-- QA: Uniqueness — accounts primary key
SELECT COUNT(*) AS total, COUNT(DISTINCT id) AS unique_accounts FROM accounts;
