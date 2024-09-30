export interface TaskModel {
  id: number;
  title: string;
  description?: string;
  createdDate: Date;
  dueDate?: Date;
  priority?: 'Low' | 'Medium' | 'High'|'None';
  isCompleted: boolean;
  projectId?: number;
  contextId?: number;
  flagged?: boolean;
  reminder?: ReminderModel;
  modifyTime?: Date;
}

export interface ProjectModel {
  id: number;
  name: string;
  description?: string;
  taskIds?: number[];
  isExpended: boolean;
  reviewedDate?: Date;
}

export interface ContextModel {
  id: number;
  name: string;
  description?: string;
  isExpended: boolean;
}



export interface ReminderModel {
  id: number;
  time: Date;
  repeatRule?: 'None' | 'Daily' | 'Weekly' | 'Monthly';
}
