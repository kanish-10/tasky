import {NextFunction, Request, Response} from "express";
import {UUID} from "node:crypto";
import jwt from "jsonwebtoken";
import {db} from "../db";
import {users} from "../db/schema";
import {eq} from "drizzle-orm";
import * as dotenv from "dotenv";

dotenv.config({path: "../../.env"});

const JWT_SECRET = process.env.JWT_SECRET!;

export interface AuthRequest extends Request {
	user?: UUID;
	token?: string;
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {
	try {
		const token = req.header("Authorization");
		if (!token) {
			res.status(401).json({error: "Unauthorized"});
			return;
		}
		const verify = jwt.verify(token, JWT_SECRET);
		if (!verify) {
			res.status(401).json({error: "Unauthorized"});
			return;
		}
		const verifiedToken = verify as {id: UUID};
		const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));
		if (!user) {
			res.status(401).json({error: "User not found"});
			return;
		}
		req.user = verifiedToken.id;
		req.token = token;
		next()
	} catch(e) {
		res.status(500).json(false);
	}
}
