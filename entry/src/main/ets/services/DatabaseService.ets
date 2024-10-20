//services/DatabaseService
import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';
import fs from '@ohos.file.fs';

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
          taskIds TEXT,
          isExpended INTEGER,
          reviewedDate INTEGER
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_PROJECTS);
      // const SQL_ADD_reviewedDate_COLUMN = `ALTER TABLE Projects ADD COLUMN reviewedDate INTEGER `
      // await this.rdbStore.executeSql(SQL_ADD_reviewedDate_COLUMN);


      const SQL_CREATE_CONTEXTS =`CREATE TABLE IF NOT EXISTS Contexts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          isExpended INTEGER
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_CONTEXTS)
      //
      // const SQL_ADD_ISEXPANDED_COLUMN = `ALTER TABLE Contexts ADD COLUMN isExpanded INTEGER DEFAULT 0`
      // await this.rdbStore.executeSql(SQL_ADD_ISEXPANDED_COLUMN);




      const SQL_CREATE_REMINDERS = `CREATE TABLE IF NOT EXISTS Reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          time INTEGER NOT NULL,
          repeatRule TEXT CHECK(repeatRule IN ('None', 'Daily', 'Weekly', 'Monthly'))
      )`;
      await this.rdbStore.executeSql(SQL_CREATE_REMINDERS);



      hilog.info(0x0000, 'DatabaseService', 'Database initialized successfully');

      // this.backupDatabase()
      await this.logDatabaseDirContents()



      return this.rdbStore;
    } catch (error) {
      hilog.error(0x0000, 'DatabaseService', `Error initializing database: ${JSON.stringify(error)}`);
      throw error;
    }
  }


  async  logDatabaseDirContents() {
    // const dbDir = getContext(this).databaseDir;
    const dbDir = `${getContext(this).databaseDir}/rdb`;
    try {
      const files = await fs.listFile(dbDir);
      hilog.info(0x0000, 'DatabaseDir', `Contents of ${dbDir}:`);
      files.forEach(file => {
        hilog.info(0x0000, 'DatabaseDir', file);
      });
    } catch (error) {
      hilog.error(0x0000, 'DatabaseDir', `Error listing directory: ${error.message}`);
    }
  }


  backupDatabase(): void {
    if (!this.rdbStore) {
      throw new Error("Database not initialized");
      hilog.info(0x001, 'DatabaseDir', 'Database not initialized')
    }

    this.rdbStore.backup('dbBackup.db', (err) => {
      if (err) {
        hilog.error(0x001,'DatabaseDir',`Failed to backup data. Code:${err.code},message:${err.message}`);
        return;
      }
      hilog.error(0x001,'DatabaseDir','backup succeed');;
    })

  }

  restoreDatabase(): void {
    this.rdbStore.restore('dbBackup.db', (err) => {
      if (err) {
        hilog.error(0x001,'DatabaseDir',`Failed to restore data. Code:${err.code},message:${err.message}`);
        return;
      }
      hilog.info(0x001,'DatabaseDir',`Succeeded in restoring data.`);
    })
  }


}
