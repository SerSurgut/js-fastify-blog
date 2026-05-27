require('dotenv').config();

const postgresConfig = {
  dialect: 'postgres',
  database: process.env.DATABASE_NAME,
  username: process.env.DATABASE_USERNAME,
  password: process.env.DATABASE_PASSWORD,
  port: process.env.DATABASE_PORT,
  host: process.env.DATABASE_HOST,
};

module.exports = {
  development: postgresConfig,
  test: postgresConfig,
  production: postgresConfig,
};
