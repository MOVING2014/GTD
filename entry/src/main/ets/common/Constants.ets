// styles.ets

// import { Color } from '@ohos.color';

export class Constants {
  // Colors
  static readonly primaryColor: string = '#76A471';
  static readonly secondaryColor: string = '#F0F0F0';
  static readonly accentColor: string = '#76A471';
  static readonly backgroundColor: string = '#fffdfffd';
  static readonly dateBackgroundColor: string = '#00fdfffd';
  static readonly textColorPrimary: string = '#333333';
  static readonly textColorSecondary: string = '#666666';
  static readonly textExpenseColor: string = '#76A471';
  static readonly textIncomeColor: string = '#99f13030';
  static readonly boarderColorPrimary: string = '#40000000'
  static readonly boarderColorSecondary: string = '#00e3e3e3'
  static readonly deleteButtonColor: string = '#99f13030';
  static readonly editButtonColor: string = '#99305af1';

  static readonly titleColorPrediction: string = '#FF3B2F';
  static readonly titleColorInbox: string = '#6B6B99';
  static readonly titleColorStarred: string = '#FF9500';
  static readonly titleColorContext: string = '#903FDE';

  static readonly dateSelectedColor: string = '#4d000000';
  static readonly dividerColor2: string = '#0d000000';


  static readonly calendarViewBackgroundIncome:  string = '#1af13030';
  static readonly calendarViewBackgroundExpense:  string = '#1a76a471';
  static readonly calendarViewBg:  string = '#08000000';


  //回顾颜色 Review模块
  static readonly reviewCompleted:  string = '#72800000';

  //Divider的颜色
  static readonly dividerColor:  string = '#56003a80';
  static readonly dividerWidth:  number = 0.7;


  //TaskItem 相关
  static readonly taskFontWeight: number = FontWeight.Regular;
  static readonly labelMarginTop: number = 3;
  static readonly taskMarginBottom: number = 4;
  static readonly taskMarginTop: number = 4;

  // Font sizes
  static readonly fontSizeSmall: number = 12;
  static readonly fontSizeMedium: number = 16;
  static readonly fontSizeLarge: number = 20;
  static readonly fontSizeExtraLarge: number = 24;

  // Font weights
  static readonly fontWeightNormal: number = 400;
  static readonly fontWeightMedium: number = 500;
  static readonly fontWeightBold: number = 700;

  // Spacing
  static readonly spacingSmall: number = 5;
  static readonly spacingMedium: number = 10;
  static readonly spacingLarge: number = 20;

  // Border radius
  static readonly borderRadiusSmall: number = 4;
  static readonly borderRadiusMedium: number = 8;
  static readonly borderRadiusLarge: number = 16;

  // Shadows
  static readonly shadowLight: {
    radius: number,
    color: string,
    offsetX: number,
    offsetY: number
  } = {
    radius: 4,
    color: Constants.boarderColorSecondary,
    offsetX: 1,
    offsetY: 1
  };

  static readonly shadowMedium: {
    radius: number,
    color: string,
    offsetX: number,
    offsetY: number
  } = {
    radius: 8,
    color: Constants.boarderColorPrimary,
    offsetX: 2,
    offsetY: 2
  };

  // Component-specific styles
  static readonly buttonHeight: number = 40;
  static readonly buttonPadding: {
    left: number,
    right: number,
    top: number,
    bottom: number
  } = {
    left: 16,
    right: 16,
    top: 8,
    bottom: 8
  };

  // Layout
  static readonly contentPadding: {
    left: number,
    right: number,
    top: number,
    bottom: number
  } = {
    left: 16,
    right: 16,
    top: 16,
    bottom: 16
  };

  // Chart colors
  static readonly chartColors: string[] = [
    '#FF6384',
    '#36A2EB',
    '#FFCE56',
    '#4BC0C0',
    '#9966FF',
    '#FF9F40'
  ];
}