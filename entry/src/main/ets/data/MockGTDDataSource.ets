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
      project: {
        id: 1,
        name: "X项目流程",
        description: "与工作相关的所有任务",
        taskIds: [1]
      },
      context: {
        id: 1,
        name: "💼办公室",
        description: "在办公室可以完成的任务"
      },
      flagged: true,
      reminder: {
        id: 1,
        time: new Date("2023-05-06T09:00:00"),
        repeatRule: "None"
      }
    },
    {
      id: 2,
      title: "购买日用品",
      createdDate: new Date("2023-05-02"),
      isCompleted: false,
      project: {
        id: 2,
        name: "网球",
        description: "与工作相关的所有任务",
        taskIds: [2]
      },
      context: {
        id: 2,
        name: "🏠家",
        description: "在家可以完成的任务"
      }
    }
  ];
  private projects: ProjectModel[] = [
    {
      id: 1,
      name: "X项目流程",
      description: "与工作相关的所有任务",
      taskIds: [1]
    },
    {
      id: 2,
      name: "网球",
      description: "与工作相关的所有任务",
      taskIds: [2]
    },
    {
      id: 3,
      name: "GTD APP",
      description: "与工作相关的所有任务",
      taskIds: []
    }

  ];

  private contexts: ContextModel[] = [
    {
      id: 1,
      name: "💼办公室",
      description: "在办公室可以完成的任务"
    },
    {
      id: 2,
      name: "🏠家",
      description: "在家可以完成的任务"
    }
  ];

  private reminders: ReminderModel[] = [
    {
      id: 1,
      time: new Date("2023-05-06T09:00:00"),
      repeatRule: "None"
    }
  ];

  // Task methods
  async getTasks(): Promise<TaskModel[]> {
    return Promise.resolve(this.tasks);
  }

  async getTaskById(taskId: number): Promise<TaskModel | null> {
    const task = this.tasks.find(t => t.id === taskId);
    return Promise.resolve(task || null);
  }

  async addTask(task: TaskModel): Promise<void> {
    task.id = this.tasks.length + 1;
    // 确保 project 和 context 对象存在
    if (task.project) {
      const fullProject = await this.getProjectById(task.project.id);
      task.project = fullProject || undefined;
    }
    if (task.context) {
      const fullContext = await this.getContextById(task.context.id);
      task.context = fullContext || undefined;
    }
    this.tasks.push(task);

  }



  async updateTask(task: TaskModel): Promise<void> {
    const index = this.tasks.findIndex(t => t.id === task.id);
    if (index !== -1) {
      // 创建一个新的任务对象，深拷贝原始任务的所有属性
      const updatedTask: TaskModel = JSON.parse(JSON.stringify(task));
      this.tasks[index] = updatedTask;
      // // 更新 project 对象
      // if (task.project.id !== undefined) {
      //   const fullProject = await this.getProjectById(task.project.id);
      //   updatedTask.project = fullProject || undefined;
      // } else {
      //   updatedTask.project = undefined;
      // }
      //
      // // 更新 context 对象
      // if (task.context.id !== undefined) {
      //   const fullContext = await this.getContextById(task.context.id);
      //   updatedTask.context = fullContext || undefined;
      // } else {
      //   updatedTask.context = undefined;
      // }
      //
      // // 更新 reminder 对象（如果存在）
      // if (task.reminder && task.reminder.id !== undefined) {
      //   const fullReminder = await this.getReminderById(task.reminder.id);
      //   updatedTask.reminder = fullReminder || undefined;
      // }
      //
      // // 更新任务
      // this.tasks[index] = updatedTask;
      return Promise.resolve();
    }
    return Promise.reject(new Error("Task not found"));
  }

  async deleteTask(taskId: number): Promise<void> {
    const index = this.tasks.findIndex(t => t.id === taskId);
    if (index !== -1) {
      this.tasks.splice(index, 1);
    }

  }

  // Project methods
  async getProjects(): Promise<ProjectModel[]> {
    return Promise.resolve(this.projects);
  }

  async getProjectById(projectId: number): Promise<ProjectModel | null> {
    const project = await this.projects.find(p => p.id === projectId);
    return Promise.resolve(project || null);
  }

  async addProject(project: ProjectModel): Promise<ProjectModel> {
    project.id = await this.projects.length + 1;
    this.projects.push(project);
    return Promise.resolve(project);
  }

  async updateProject(project: ProjectModel): Promise<ProjectModel> {
    const index = await this.projects.findIndex(p => p.id === project.id);
    if (index !== -1) {
      this.projects[index] = project;
      return Promise.resolve(project);
    }
    return Promise.reject(new Error("Project not found"));
  }

  async deleteProject(projectId: number): Promise<boolean> {
    const index = this.projects.findIndex(p => p.id === projectId);
    if (index !== -1) {
      // 删除项目
      this.projects.splice(index, 1);

      // 更新相关任务
      this.tasks = this.tasks.map(task => {
        if (task.project && task.project.id === projectId) {
          return { ...task, project: undefined };
        }
        return task;
      });

      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  // Context methods
  async getContexts(): Promise<ContextModel[]> {
    return Promise.resolve(this.contexts);
  }
  async getContextById(contextId: number): Promise<ContextModel | null> {
    const context = this.contexts.find(c => c.id === contextId);
    return Promise.resolve(context || null);
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
      // 删除上下文
      this.contexts.splice(index, 1);

      // 更新相关任务
      this.tasks = this.tasks.map(task => {
        if (task.context && task.context.id === contextId) {
          return { ...task, context: undefined };
        }
        return task;
      });

      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  // Reminder methods
  async getReminders(): Promise<ReminderModel[]> {
    return Promise.resolve(this.reminders);
  }
  async getReminderById(reminderId: number): Promise<ReminderModel | null> {
    const reminder = this.reminders.find(r => r.id === reminderId);
    return Promise.resolve(reminder || null);
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

  async deleteReminder(reminderId: number): Promise<boolean> {
    const index = this.reminders.findIndex(r => r.id === reminderId);
    if (index !== -1) {
      // 删除提醒
      this.reminders.splice(index, 1);

      // 更新相关任务
      this.tasks.forEach(task => {
        if (task.reminder && task.reminder.id === reminderId) {
          task.reminder = undefined;
        }
      });

      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }
}

