//services/DatabaseService
import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';

export class DatabaseService {
  private static instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore;

  private constructor() {}

  public static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }


  async initDatabase(): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) {
      return this.rdbStore;
    }

    try {
      const context = getContext(this);
      const databaseName = 'GTDDB';
      const STORE_CONFIG = {
        name: databaseName,
        securityLevel: relationalStore.SecurityLevel.S1
      };


      const SQL_CREATE_TASKS  = `CREATE TABLE IF NOT EXISTS Tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          createdDate INTEGER NOT NULL,
          dueDate INTEGER,
          priority TEXT CHECK(priority IN ('Low', 'Medium', 'High', 'None')),
          isCompleted INTEGER NOT NULL,
          projectId INTEGER,
          contextId INTEGER,
          flagged INTEGER,
          reminderId INTEGER,
          modifyTime INTEGER,
          FOREIGN KEY (projectId) REFERENCES Projects(id),
          FOREIGN KEY (contextId) REFERENCES Contexts(id),
          FOREIGN KEY (reminderId) REFERENCES Reminders(id)
      )`;

      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(SQL_CREATE_TASKS);

      const SQL_CREATE_PROJECTS =`CREATE TABLE IF NOT EXISTS Projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          isExpended INTEGER
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_PROJECTS);

      const SQL_CREATE_CONTEXTS =`CREATE TABLE IF NOT EXISTS Contexts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_CONTEXTS);

      const SQL_CREATE_REMINDERS = `CREATE TABLE IF NOT EXISTS Reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          time INTEGER NOT NULL,
          repeatRule TEXT CHECK(repeatRule IN ('None', 'Daily', 'Weekly', 'Monthly'))
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_REMINDERS);



      hilog.info(0x0000, 'DatabaseService', 'Database initialized successfully');
      return this.rdbStore;
    } catch (error) {
      hilog.error(0x0000, 'DatabaseService', `Error initializing database: ${error}`);
      throw error;
    }
  }
}
