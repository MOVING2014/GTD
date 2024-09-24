export interface TaskModel {
  id: number;
  title: string;
  description?: string;
  createdDate: Date;
  dueDate?: Date;
  priority?: 'Low' | 'Medium' | 'High'|'None';
  isCompleted: boolean;
  project?: ProjectModel;
  context?: ContextModel;
  flagged?: boolean;
  reminder?: ReminderModel;
  modifyTime?: Date;
}

export interface ProjectModel {
  id: number;
  name: string;
  description?: string;
  taskIds?: number[];
}

export interface ContextModel {
  id: number;
  name: string;
  description?: string;
}



export interface ReminderModel {
  id: number;
  time: Date;
  repeatRule?: 'None' | 'Daily' | 'Weekly' | 'Monthly';
}
