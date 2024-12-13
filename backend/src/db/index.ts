import {Pool} from "pg";
import {drizzle} from "drizzle-orm/node-postgres";
import * as dotenv from "dotenv";

dotenv.config({path: "../../.env"});

const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
})

export const db = drizzle(pool)
