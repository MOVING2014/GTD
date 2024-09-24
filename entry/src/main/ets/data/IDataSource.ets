import { TaskModel, ProjectModel, ContextModel, ReminderModel } from '../models/IModels';

export interface TaskDataSource {
  getTasks(): Promise<TaskModel[]>;
  getTaskById(taskId: number): Promise<TaskModel | null>;
  addTask(task: TaskModel): Promise<void>;
  updateTask(task: TaskModel): Promise<void>;
  deleteTask(taskId: number): Promise<void>;
}

export interface ProjectDataSource {
  getProjects(): Promise<ProjectModel[]>;
  getProjectById(projectId: number): Promise<ProjectModel | null>;
  addProject(project: ProjectModel): Promise<ProjectModel>;
  updateProject(project: ProjectModel): Promise<ProjectModel>;
  deleteProject(projectId: number): Promise<boolean>;
}

export interface ContextDataSource {
  getContexts(): Promise<ContextModel[]>;
  addContext(context: ContextModel): Promise<ContextModel>;
  getContextById(contextId: number): Promise<ContextModel | null>;
  updateContext(context: ContextModel): Promise<ContextModel>;
  deleteContext(contextId: number): Promise<boolean>;
}

export interface ReminderDataSource {
  getReminders(): Promise<ReminderModel[]>;
  getReminderById(reminderId: number): Promise<ReminderModel | null>;
  addReminder(reminder: ReminderModel): Promise<ReminderModel>;
  updateReminder(reminder: ReminderModel): Promise<ReminderModel>;
  deleteReminder(reminderId: number): Promise<boolean>;
}

// 如果需要，可以创建一个聚合接口
export interface GTDDataSource extends TaskDataSource, ProjectDataSource, ContextDataSource, ReminderDataSource {}