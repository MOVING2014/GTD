import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';
import { TaskModel, ProjectModel, ContextModel, ReminderModel } from '../models/IModels';
import { DatabaseService } from '../services/DatabaseService';
import { GTDDataSource } from './IDataSource';

export class DatabaseGTDDataSource implements GTDDataSource {

  private dbService: DatabaseService;
  // private db: relationalStore.RdbStore

  constructor() {
    this.dbService = DatabaseService.getInstance();
  }

  // Task methods
  async getTasks(): Promise<TaskModel[]> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Tasks';
    const resultSet = await db.querySql(sql);
    return this.resultSetToTasks(resultSet);
  }

  async getTaskById(taskId: number): Promise<TaskModel | null> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Tasks WHERE id = ?';
    const resultSet = await db.querySql(sql, [taskId]);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      return this.resultSetToTask(resultSet);
    }
    return null;
  }

  async addTask(task: TaskModel): Promise<TaskModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.taskToValuesBucket(task);
    const insertId = await db.insert('Tasks', valuesBucket);
    return { ...task, id: insertId };
  }

  async updateTask(task: TaskModel): Promise<TaskModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.taskToValuesBucket(task);
    let predicates = new relationalStore.RdbPredicates("Tasks");
    predicates.equalTo("id", `${task.id}`);
    await db.update(valuesBucket, predicates);
    return task;
  }

  async deleteTask(taskId: number): Promise<boolean> {
    const db = await this.dbService.initDatabase();
    let predicates = new relationalStore.RdbPredicates("Tasks");
    predicates.equalTo("id", `${taskId}`);
    const deletedRows = await db.delete(predicates);
    return deletedRows > 0;
  }

  // Project methods
  async getProjects(): Promise<ProjectModel[]> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Projects';
    const resultSet = await db.querySql(sql);
    return this.resultSetToProjects(resultSet);
  }

  async getProjectById(projectId: number): Promise<ProjectModel | null> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Projects WHERE id = ?';
    const resultSet = await db.querySql(sql, [projectId]);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      return this.resultSetToProject(resultSet);
    }
    return null;
  }

  async addProject(project: ProjectModel): Promise<ProjectModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.projectToValuesBucket(project);
    hilog.debug(0x003, 'Database', `ADD PROJECTS： ${JSON.stringify(valuesBucket)}`)
    const insertId = await db.insert('Projects', valuesBucket);
    return { ...project, id: insertId };
  }

  async updateProject(project: ProjectModel): Promise<ProjectModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.projectToValuesBucket(project);
    let predicates = new relationalStore.RdbPredicates("Projects");
    predicates.equalTo("id", `${project.id}`);
    await db.update( valuesBucket, predicates);
    return project;
  }

  async deleteProject(projectId: number): Promise<boolean> {
    const db = await this.dbService.initDatabase();
    let predicates = new relationalStore.RdbPredicates("Projects");
    predicates.equalTo("id", `${projectId}`);
    const deletedRows = await db.delete(predicates);
    return deletedRows > 0;
  }

  // Context methods
  async getContexts(): Promise<ContextModel[]> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Contexts';
    const resultSet = await db.querySql(sql);
    return this.resultSetToContexts(resultSet);
  }

  async getContextById(contextId: number): Promise<ContextModel | null> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Contexts WHERE id = ?';
    const resultSet = await db.querySql(sql, [contextId]);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      return this.resultSetToContext(resultSet);
    }
    return null;
  }

  async addContext(context: ContextModel): Promise<ContextModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.contextToValuesBucket(context);
    hilog.debug(0x003, 'Database', `valuesBucket ${JSON.stringify(valuesBucket)}`)

      await db.insert('Contexts', valuesBucket, (err, rowId) => {
        if (err) {
          hilog.debug(0x003, 'Database', `Failed to insert data. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`Succeeded in inserting data. rowId:${rowId}`);

      });
      // hilog.debug(0x003, 'Database', `insertId: ${insertId}`)



    return context
  }

  async updateContext(context: ContextModel): Promise<ContextModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.contextToValuesBucket(context);
    let predicates = new relationalStore.RdbPredicates("Contexts");
    predicates.equalTo("id", `${context.id}`);
    await db.update(valuesBucket, predicates);
    return context;
  }

  async deleteContext(contextId: number): Promise<boolean> {
    const db = await this.dbService.initDatabase();
    let predicates = new relationalStore.RdbPredicates("Contexts");
    predicates.equalTo("id", `${contextId}`);
    const deletedRows = await db.delete(predicates);
    return deletedRows > 0;
  }

  // Reminder methods
  async getReminders(): Promise<ReminderModel[]> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Reminders';
    const resultSet = await db.querySql(sql);
    return this.resultSetToReminders(resultSet);
  }

  async getReminderById(reminderId: number): Promise<ReminderModel | null> {
    const db = await this.dbService.initDatabase();
    const sql = 'SELECT * FROM Reminders WHERE id = ?';
    const resultSet = await db.querySql(sql, [reminderId]);
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      return this.resultSetToReminder(resultSet);
    }
    return null;
  }

  async addReminder(reminder: ReminderModel): Promise<ReminderModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.reminderToValuesBucket(reminder);
    const insertId = await db.insert('Reminders', valuesBucket);
    return { ...reminder, id: insertId };
  }

  async updateReminder(reminder: ReminderModel): Promise<ReminderModel> {
    const db = await this.dbService.initDatabase();
    const valuesBucket = this.reminderToValuesBucket(reminder);
    let predicates = new relationalStore.RdbPredicates("Contexts");
    predicates.equalTo("id", `${reminder.id}`);
    await db.update(valuesBucket, predicates);
    return reminder;
  }

  async deleteReminder(reminderId: number): Promise<boolean> {
    const db = await this.dbService.initDatabase();
    let predicates = new relationalStore.RdbPredicates("Contexts");
    predicates.equalTo("id", `${reminderId}`);
    const deletedRows = await db.delete(predicates);
    return deletedRows > 0;
  }

  // Helper methods for converting between models and database rows
  private resultSetToTasks(resultSet: relationalStore.ResultSet): TaskModel[] {
    const tasks: TaskModel[] = [];
    while (resultSet.goToNextRow()) {
      tasks.push(this.resultSetToTask(resultSet));
    }
    return tasks;
  }

  private resultSetToTask(resultSet: relationalStore.ResultSet): TaskModel {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      createdDate: new Date(resultSet.getLong(resultSet.getColumnIndex('createdDate'))),
      dueDate: resultSet.getLong(resultSet.getColumnIndex('dueDate')) ? new Date(resultSet.getLong(resultSet.getColumnIndex('dueDate'))) : undefined,
      priority: resultSet.getString(resultSet.getColumnIndex('priority')) as 'Low' | 'Medium' | 'High' | 'None',
      isCompleted: resultSet.getLong(resultSet.getColumnIndex('isCompleted')) === 1,
      projectId: resultSet.getLong(resultSet.getColumnIndex('projectId')),
      contextId: resultSet.getLong(resultSet.getColumnIndex('contextId')),
      flagged: resultSet.getLong(resultSet.getColumnIndex('flagged')) === 1,
      modifyTime: resultSet.getLong(resultSet.getColumnIndex('modifyTime')) ? new Date(resultSet.getLong(resultSet.getColumnIndex('modifyTime'))) : undefined,
    };
  }

  private taskToValuesBucket(task: TaskModel): relationalStore.ValuesBucket {
    return {
      title: task.title,
      description: task.description,
      createdDate: task.createdDate.getTime(),
      dueDate: task.dueDate?.getTime(),
      priority: task.priority,
      isCompleted: task.isCompleted ? 1 : 0,
      projectId: task.projectId,
      contextId: task.contextId,
      flagged: task.flagged ? 1 : 0,
      modifyTime: task.modifyTime?.getTime(),
    };
  }

  // Similar methods for Project, Context, and Reminder...
  // (I've omitted these for brevity, but they would follow the same pattern as the Task methods)

  private resultSetToProjects(resultSet: relationalStore.ResultSet): ProjectModel[] {
    const projects: ProjectModel[] = [];
    while (resultSet.goToNextRow()) {
      projects.push(this.resultSetToProject(resultSet));
    }
    return projects;
  }

  private resultSetToProject(resultSet: relationalStore.ResultSet): ProjectModel {
    const project =  {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      taskIds: this.deSeri(resultSet.getString(resultSet.getColumnIndex('taskIds'))),
      isExpended: resultSet.getLong(resultSet.getColumnIndex('isExpended')) === 1,
    };
    hilog.debug(0x000, ' DatabaseGTDDataSource:resultSetToProject', `project : ${JSON.stringify(project)}}`)

    return project
  }

  private seri(ids: number[]){
    return JSON.stringify(ids)
  }
  private deSeri(taskIdsString: string): number[] {
    if(!taskIdsString) { return [] }
    const taskIds = JSON.parse(taskIdsString) as number[];
    return taskIds
  }


  private projectToValuesBucket(project: ProjectModel): relationalStore.ValuesBucket {
    const valueBucket =  {
      name: project.name,
      description: project.description,
      taskIds: project.taskIds ? this.seri(project.taskIds) : "[]" ,
      isExpended: project.isExpended ? 1:0
    };
    hilog.debug(0x000, ' DatabaseGTDDataSource:projectToValuesBucket', `valueBUcket: ${JSON.stringify(valueBucket)}}`)
    return valueBucket
  }

  private resultSetToContexts(resultSet: relationalStore.ResultSet): ContextModel[] {
    const contexts: ContextModel[] = [];
    while (resultSet.goToNextRow()) {
      contexts.push(this.resultSetToContext(resultSet));
    }
    return contexts;
  }

  private resultSetToContext(resultSet: relationalStore.ResultSet): ContextModel {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      isExpended: resultSet.getLong(resultSet.getColumnIndex('isExpended')) === 1
    };
  }

  private contextToValuesBucket(context: ContextModel): relationalStore.ValuesBucket {
    return {
      name: context.name,
      description: context.description,
      isExpended: context.isExpended ? 1:0
    };
  }

  private resultSetToReminders(resultSet: relationalStore.ResultSet): ReminderModel[] {
    const reminders: ReminderModel[] = [];
    while (resultSet.goToNextRow()) {
      reminders.push(this.resultSetToReminder(resultSet));
    }
    return reminders;
  }

  private resultSetToReminder(resultSet: relationalStore.ResultSet): ReminderModel {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      time: new Date(resultSet.getLong(resultSet.getColumnIndex('time'))),
      repeatRule: resultSet.getString(resultSet.getColumnIndex('repeatRule')) as 'None' | 'Daily' | 'Weekly' | 'Monthly',
    };
  }

  private reminderToValuesBucket(reminder: ReminderModel): relationalStore.ValuesBucket {
    return {
      time: reminder.time.getTime(),
      repeatRule: reminder.repeatRule,
    };
  }


}