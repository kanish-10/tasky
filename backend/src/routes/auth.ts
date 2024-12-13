import {Router, Request, Response} from "express";
import {db} from "../db"
import {NewUser, users} from "../db/schema";
import {eq} from "drizzle-orm";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import * as dotenv from "dotenv";
import {auth, AuthRequest} from "../middleware/auth";

dotenv.config({path: "../../.env"});

const JWT_SECRET = process.env.JWT_SECRET!;

const authRouter = Router();

interface SignUpBody {
	name: string;
	email: string;
	password: string;
}

interface LoginBody {
	email: string;
	password: string;
}

authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
	try {
		const {name, email, password} = req.body;
		const userExist = await db.select().from(users).where(eq(users.email, email));
		if (userExist.length) {
			res.status(400).json({error: "User already exists"});
			return;
		}
		const hashedPassword = await bcryptjs.hash(password, 8);
		const newUser: NewUser = {
			name, email, password: hashedPassword,
		};
		const [user] = await db.insert(users).values(newUser).returning();
		res.status(201).json(user);
	} catch (e) {
		res.status(500).json({error: e})
	}
})

authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
	const {email, password} = req.body;
	const [userExist] = await db.select().from(users).where(eq(users.email, email));
	if (!userExist) {
		res.status(400).json({error: "User don't exist"});
		return;
	}
	const isMatch = await bcryptjs.compare(password, userExist.password);
	if (!isMatch) {
		res.status(400).json({error: "Invalid credentials"});
		return;
	}
	const token = jwt.sign({id: userExist.id}, JWT_SECRET)
	res.status(200).json({token, ...userExist});
})

authRouter.post("/validate", async (req, res) => {
	try {
		const token = req.header("Authorization");
		if (!token) {
			res.json(false);
			return;
		}
		const verify = jwt.verify(token, JWT_SECRET);
		if (!verify) {
			res.json(false);
			return;
		}
		const verifiedToken = verify as { id: string };
		const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));
		if (!user) {
			res.json(false);
			return;
		}
		res.json(true);
	} catch (e) {
		res.status(500).json(false);
	}
})

authRouter.get("/", auth, async (req: AuthRequest, res) => {
	try {
		if (!req.user) {
			res.status(401).json({error: "Unauthorized"});
			return;
		}
		const [user] = await db.select().from(users).where(eq(users.id, req.user));
		if (!user) {
			res.status(401).json({error: "User not found"});
			return;
		}
		res.json({...user, token: req.token});
	} catch (e) {
		res.status(500).json({error: e});
	}
})

export default authRouter;
