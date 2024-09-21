import { TaskModel, ProjectModel, ContextModel, ReminderModel } from '../models/IModels';

export interface TaskDataSource {
  getTasks(): Promise<TaskModel[]>;
  addTask(task: TaskModel): Promise<TaskModel>;
  updateTask(task: TaskModel): Promise<TaskModel>;
  deleteTask(taskId: number): Promise<boolean>;
}

export interface ProjectDataSource {
  getProjects(): Promise<ProjectModel[]>;
  addProject(project: ProjectModel): Promise<ProjectModel>;
  updateProject(project: ProjectModel): Promise<ProjectModel>;
  deleteProject(projectId: number): Promise<boolean>;
}

export interface ContextDataSource {
  getContexts(): Promise<ContextModel[]>;
  addContext(context: ContextModel): Promise<ContextModel>;
  updateContext(context: ContextModel): Promise<ContextModel>;
  deleteContext(contextId: number): Promise<boolean>;
}

export interface ReminderDataSource {
  getReminders(): Promise<ReminderModel[]>;
  addReminder(reminder: ReminderModel): Promise<ReminderModel>;
  updateReminder(reminder: ReminderModel): Promise<ReminderModel>;
  deleteReminder(reminderId: string): Promise<boolean>;
}

// 如果需要，可以创建一个聚合接口
export interface GTDDataSource extends TaskDataSource, ProjectDataSource, ContextDataSource, ReminderDataSource {}