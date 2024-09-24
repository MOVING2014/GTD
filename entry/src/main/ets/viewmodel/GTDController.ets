import { ContextModel, ProjectModel, ReminderModel, TaskModel } from '../models/IModels';
import { GTDDataSource } from '../data/IDataSource';
import { MockGTDDataSource } from '../data/MockGTDDataSource';

export class GTDController {
  private dataSource: GTDDataSource;

  projectCache: Record<number, ProjectModel | null> = {};
  contextCache: Record<number, ContextModel | null> = {};
  reminderCache: Record<number, ReminderModel |null> = {};
  private observers: Set<() => void> = new Set();


  addObserver(observer: () => void) {
    this.observers.add(observer);
  }

  removeObserver(observer: () => void) {
    this.observers.delete(observer);
  }

  notifyObservers() {
    this.observers.forEach(observer => observer());
  }


  async initializeCache(): Promise<void> {
    try {
      const projects = await this.getAllProjects();
      projects.forEach(project => {
        this.projectCache[project.id] = project;
      });

      const contexts = await this.getAllContexts();
      contexts.forEach(context => {
        this.contextCache[context.id] = context;
      });

      const reminders = await this.getAllReminders();
      reminders.forEach(reminder => {
        this.reminderCache[reminder.id] = reminder;
      });

      console.log(' initialized successfully');
    } catch (error) {
      console.error('Error initializing :', error);
    }
  }
  // 修改 getProjectById 方法以使用缓存
  async getProjectById(id: number): Promise<ProjectModel | null> {
    if (this.projectCache[id] === undefined) {
      try {
        const project = await this.dataSource.getProjectById(id);
        this.projectCache[id] = project;
      } catch (error) {
        console.error(`Error fetching project with id ${id}:`, error);
        this.projectCache[id] = null;
      }
    }
    return this.projectCache[id];
  }


  constructor(dataSource: GTDDataSource = new MockGTDDataSource()) {
    this.dataSource = dataSource;
  }

  // Task methods
  async getAllTasks(): Promise<TaskModel[]> {
    return this.dataSource.getTasks();
  }

  async getTaskById(id: number): Promise<TaskModel> {
    return this.dataSource.getTaskById(id)
  }

  async createTask(task: Omit<TaskModel, 'id'>): Promise<TaskModel> {
    const newTask: TaskModel = { ...task, id: 0 };
    this.notifyObservers()
    return this.dataSource.addTask(newTask);
  }

  async updateTask(task: TaskModel): Promise<TaskModel> {
    this.notifyObservers()
    return this.dataSource.updateTask(task);
  }

  async deleteTask(taskId: number): Promise<boolean> {
    this.notifyObservers()
    return this.dataSource.deleteTask(taskId);
  }

  async getTasksByProject(projectId: number): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    return tasks.filter(task => task.project.id === projectId);
  }



  async getTasksByContext(contextId: number): Promise<TaskModel[]> {
    const tasks = await this.dataSource.getTasks();
    return tasks.filter(task => task.context.id === contextId);
  }

  // Project methods
  async getAllProjects(): Promise<ProjectModel[]> {
    return this.dataSource.getProjects();
  }

  // async getProjectById(id: number): Promise<ProjectModel> {
  //   return await this.dataSource.getProjectById(id)
  // }
  //

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

  async getContextById(id: number): Promise<ContextModel> {
    return this.dataSource.getContextById(id)
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
  async getReminderById(id: number): Promise<ReminderModel> {
    return this.dataSource.getReminderById(id)
  }
  async createReminder(reminder: ReminderModel): Promise<ReminderModel> {
    return this.dataSource.addReminder(reminder);
  }

  async updateReminder(reminder: ReminderModel): Promise<ReminderModel> {
    return this.dataSource.updateReminder(reminder);
  }

  async deleteReminder(reminderId: number): Promise<boolean> {
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