import {Router} from "express";
import {auth, AuthRequest} from "../middleware/auth";
import {NewTask, tasks} from "../db/schema";
import {db} from "../db";
import {eq} from "drizzle-orm";

const taskRouter = Router();

taskRouter.post("/", auth, async(req:AuthRequest, res) => {
	try {
		req.body = {...req.body, due_at: new Date(req.body.due_at) ,uid: req.user};
		const newTask: NewTask = req.body;
		const [task] = await db.insert(tasks).values(newTask).returning();
		res.status(201).json(task);
	} catch(e) {
		res.status(500).json({error: e});
	}
})

taskRouter.get("/", auth, async(req:AuthRequest, res) => {
	try {
		const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user!));
		res.json(allTasks);
	} catch(e) {
		res.status(500).json({error: e});
	}
})

taskRouter.delete("/", auth, async(req:AuthRequest, res) => {
	try {
		const {taskId} = req.body;
		await db.delete(tasks).where(eq(taskId, tasks.id));
		res.json(true);
	} catch(e) {
		res.status(500).json({error: e});
	}
})

taskRouter.post("/sync", auth, async (req: AuthRequest, res) => {
	try {
		// req.body = { ...req.body, dueAt: new Date(req.body.dueAt), uid: req.user };
		const tasksList = req.body;

		const filteredTasks: NewTask[] = [];

		for (let t of tasksList) {
			t = {
				...t,
				due_at: new Date(t.due_at),
				created_at: new Date(t.created_at),
				updated_at: new Date(t.updated_at),
				uid: req.user,
			};
			filteredTasks.push(t);
		}

		const pushedTasks = await db
			.insert(tasks)
			.values(filteredTasks)
			.returning();

		res.status(201).json(pushedTasks);
	} catch (e) {
		console.log(e);
		res.status(500).json({ error: e });
	}
});

export default taskRouter