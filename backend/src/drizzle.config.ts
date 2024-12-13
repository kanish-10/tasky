import {defineConfig} from "drizzle-kit";
import * as dotenv from "dotenv";
dotenv.config({path: "../.env"});

const database = process.env.POSTGRES_DB!;
const user = process.env.POSTGRES_USER!;
const password = process.env.POSTGRES_PASSWORD!;

export default defineConfig({
	dialect: "postgresql",
	schema: "./db/schema.ts",
	out: "./drizzle",
	dbCredentials: {
		host: "localhost",
		port: 5432,
		database,
		user,
		password,
		ssl: false
	}
})
