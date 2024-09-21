import { ContextModel, ProjectModel, ReminderModel, TaskModel } from '../models/IModels';
import { GTDDataSource } from './IDataSource';

export  class MockGTDDataSource implements GTDDataSource {
  private tasks: TaskModel[] = [
    {
      id: 1,
      title: "完成项目报告",
      description: "准备下周的项目进度报告",
      createdDate: new Date("2023-05-01"),
      dueDate: new Date("2023-05-07"),
      priority: "High",
      isCompleted: false,
      projectId: "1",
      contextId: "1",
      flagged: true,
      reminder: {
        id: "1",
        time: new Date("2023-05-06T09:00:00"),
        repeatRule: "None"
      }
    },
    {
      id: 2,
      title: "购买日用品",
      createdDate: new Date("2023-05-02"),
      isCompleted: false,
      contextId: "2"
    }
  ];

  private projects: ProjectModel[] = [
    {
      id: 1,
      name: "工作项目",
      description: "与工作相关的所有任务",
      taskIds: ["1"]
    }
  ];

  private contexts: ContextModel[] = [
    {
      id: 1,
      name: "办公室",
      description: "在办公室可以完成的任务"
    },
    {
      id: 2,
      name: "家",
      description: "在家可以完成的任务"
    }
  ];

  private reminders: ReminderModel[] = [
    {
      id: "1",
      time: new Date("2023-05-06T09:00:00"),
      repeatRule: "None"
    }
  ];

  // Task methods
  async getTasks(): Promise<TaskModel[]> {
    return Promise.resolve(this.tasks);
  }

  async addTask(task: TaskModel): Promise<TaskModel> {
    task.id = this.tasks.length + 1;
    this.tasks.push(task);
    return Promise.resolve(task);
  }

  async updateTask(task: TaskModel): Promise<TaskModel> {
    const index = this.tasks.findIndex(t => t.id === task.id);
    if (index !== -1) {
      this.tasks[index] = task;
      return Promise.resolve(task);
    }
    return Promise.reject(new Error("Task not found"));
  }

  async deleteTask(taskId: number): Promise<boolean> {
    const index = this.tasks.findIndex(t => t.id === taskId);
    if (index !== -1) {
      this.tasks.splice(index, 1);
      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  // Project methods
  async getProjects(): Promise<ProjectModel[]> {
    return Promise.resolve(this.projects);
  }

  async addProject(project: ProjectModel): Promise<ProjectModel> {
    project.id = this.projects.length + 1;
    this.projects.push(project);
    return Promise.resolve(project);
  }

  async updateProject(project: ProjectModel): Promise<ProjectModel> {
    const index = this.projects.findIndex(p => p.id === project.id);
    if (index !== -1) {
      this.projects[index] = project;
      return Promise.resolve(project);
    }
    return Promise.reject(new Error("Project not found"));
  }

  async deleteProject(projectId: number): Promise<boolean> {
    const index = this.projects.findIndex(p => p.id === projectId);
    if (index !== -1) {
      this.projects.splice(index, 1);
      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  // Context methods
  async getContexts(): Promise<ContextModel[]> {
    return Promise.resolve(this.contexts);
  }

  async addContext(context: ContextModel): Promise<ContextModel> {
    context.id = this.contexts.length + 1;
    this.contexts.push(context);
    return Promise.resolve(context);
  }

  async updateContext(context: ContextModel): Promise<ContextModel> {
    const index = this.contexts.findIndex(c => c.id === context.id);
    if (index !== -1) {
      this.contexts[index] = context;
      return Promise.resolve(context);
    }
    return Promise.reject(new Error("Context not found"));
  }

  async deleteContext(contextId: number): Promise<boolean> {
    const index = this.contexts.findIndex(c => c.id === contextId);
    if (index !== -1) {
      this.contexts.splice(index, 1);
      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  // Reminder methods
  async getReminders(): Promise<ReminderModel[]> {
    return Promise.resolve(this.reminders);
  }

  async addReminder(reminder: ReminderModel): Promise<ReminderModel> {
    this.reminders.push(reminder);
    return Promise.resolve(reminder);
  }

  async updateReminder(reminder: ReminderModel): Promise<ReminderModel> {
    const index = this.reminders.findIndex(r => r.id === reminder.id);
    if (index !== -1) {
      this.reminders[index] = reminder;
      return Promise.resolve(reminder);
    }
    return Promise.reject(new Error("Reminder not found"));
  }

  async deleteReminder(reminderId: string): Promise<boolean> {
    const index = this.reminders.findIndex(r => r.id === reminderId);
    if (index !== -1) {
      this.reminders.splice(index, 1);
      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }
}

// 导出模拟数据源实例
// export const mockGTDDataSource: GTDDataSource = new MockGTDDataSource();