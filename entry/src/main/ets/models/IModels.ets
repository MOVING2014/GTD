export interface TaskModel {
  id: number;
  title: string;
  description?: string;
  createdDate: Date;
  dueDate?: Date;
  priority?: 'Low' | 'Medium' | 'High';
  isCompleted: boolean;
  projectId?: string;
  contextId?: string;
  flagged?: boolean;
  reminder?: ReminderModel;
}

export interface ProjectModel {
  id: number;
  name: string;
  description?: string;
  taskIds?: string[];
}

export interface ContextModel {
  id: number;
  name: string;
  description?: string;
}



export interface ReminderModel {
  id: string;
  time: Date;
  repeatRule?: 'None' | 'Daily' | 'Weekly' | 'Monthly';
}
