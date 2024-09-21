import { ContextModel, ProjectModel, ReminderModel, TaskModel } from '../models/IModels';
import { GTDDataSource } from '../data/IDataSource';
import { MockGTDDataSource } from '../data/MockGTDDataSource';

export class GTDController {
  private dataSource: GTDDataSource;

  constructor(dataSource: GTDDataSource = new MockGTDDataSource()) {
    this.dataSource = dataSource;
  }

  // Task methods
  async getAllTasks(): Promise<TaskModel[]> {
    return this.dataSource.getTasks();
  }

  async createTask(task: Omit<TaskModel, 'id'>): Promise<TaskModel> {
    const newTask: TaskModel = { ...task, id: 0 };
    return this.dataSource.addTask(newTask);
  }

  async updateTask(task: TaskModel): Promise<TaskModel> {
    return this.dataSource.updateTask(task);
  }

  async deleteTask(taskId: number): Promise<boolean> {
    return this.dataSource.deleteTask(taskId);
  }

  async getTasksByProject(projectId: string): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    return tasks.filter(task => task.projectId === projectId);
  }

  async getTasksByContext(contextId: string): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    return tasks.filter(task => task.contextId === contextId);
  }

  // Project methods
  async getAllProjects(): Promise<ProjectModel[]> {
    return this.dataSource.getProjects();
  }

  async createProject(project: Omit<ProjectModel, 'id'>): Promise<ProjectModel> {
    const newProject: ProjectModel = { ...project, id: 0 };
    return this.dataSource.addProject(newProject);
  }

  async updateProject(project: ProjectModel): Promise<ProjectModel> {
    return this.dataSource.updateProject(project);
  }

  async deleteProject(projectId: number): Promise<boolean> {
    return this.dataSource.deleteProject(projectId);
  }

  // Context methods
  async getAllContexts(): Promise<ContextModel[]> {
    return this.dataSource.getContexts();
  }

  async createContext(context: Omit<ContextModel, 'id'>): Promise<ContextModel> {
    const newContext: ContextModel = { ...context, id: 0 };
    return this.dataSource.addContext(newContext);
  }

  async updateContext(context: ContextModel): Promise<ContextModel> {
    return this.dataSource.updateContext(context);
  }

  async deleteContext(contextId: number): Promise<boolean> {
    return this.dataSource.deleteContext(contextId);
  }

  // Reminder methods
  async getAllReminders(): Promise<ReminderModel[]> {
    return this.dataSource.getReminders();
  }

  async createReminder(reminder: ReminderModel): Promise<ReminderModel> {
    return this.dataSource.addReminder(reminder);
  }

  async updateReminder(reminder: ReminderModel): Promise<ReminderModel> {
    return this.dataSource.updateReminder(reminder);
  }

  async deleteReminder(reminderId: string): Promise<boolean> {
    return this.dataSource.deleteReminder(reminderId);
  }

  // Additional business logic methods
  async getOverdueTasks(): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    const now = new Date();
    return tasks.filter(task => task.dueDate && task.dueDate < now && !task.isCompleted);
  }

  async getUpcomingTasks(days: number): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    const now = new Date();
    const futureDate = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
    return tasks.filter(task => task.dueDate && task.dueDate >= now && task.dueDate <= futureDate && !task.isCompleted);
  }

  async getFlaggedTasks(): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    return tasks.filter(task => task.flagged);
  }

  async completeTask(taskId: number): Promise<TaskModel> {
    const task = (await this.dataSource.getTasks()).find(t => t.id === taskId);
    if (!task) {
      throw new Error("Task not found");
    }
    task.isCompleted = true;
    return this.dataSource.updateTask(task);
  }
}

// 导出 controller 实例
export const gtdController = new GTDController();