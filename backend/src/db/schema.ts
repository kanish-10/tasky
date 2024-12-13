import {pgTable, text, timestamp, uuid} from "drizzle-orm/pg-core";

export const users = pgTable("users", {
	id: uuid("id").primaryKey().defaultRandom(),
	name: text("name").notNull(),
	email: text("email").notNull().unique(),
	password: text("password").notNull(),
	created_at: timestamp("created_at").defaultNow(),
	updated_at: timestamp("updated_at").defaultNow(),
})

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

export const tasks = pgTable("tasks", {
	id: uuid("id").primaryKey().defaultRandom(),
	title: text("title").notNull(),
	description: text("description").notNull(),
	color: text("color").notNull(),
	uid: uuid("uid").notNull().references(() => users.id, {onDelete: "cascade"}),
	due_at: timestamp("due_at").$defaultFn(() => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)),
	created_at: timestamp("created_at").defaultNow(),
	updated_at: timestamp("updated_at").defaultNow(),
})

export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;