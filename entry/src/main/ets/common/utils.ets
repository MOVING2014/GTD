/**
 * 格式化资产/负债金额
 * 如果金额大于等于 10000，则以"万元"为单位显示，保留一位小数
 * 否则直接显示原值，添加"元"后缀
 * @param amount 要格式化的金额
 * @returns 格式化后的金额字符串
 */
export function formatAssetDebt(amount: number): string {
  if (amount >= 10000) {
    const inWan = amount / 10000;
    return `${inWan.toFixed(1)}万`;
  } else {
    return `${amount.toFixed(1)}元`;
  }
}


export function  formatDate(dateString: string, timeOnly: boolean = false): string {
  const date = new Date(dateString);
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const month = date.getMonth() + 1;
  const day = date.getDate();
  const weekDay = ['日', '一', '二', '三', '四', '五', '六'][date.getDay()];

  let result = '';

  if (timeOnly) {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    result = `${hours}:${minutes}:${seconds}`;
  } else {
    if (isSameDay(date, today)) {
      result = `今天 星期${weekDay}`;
    } else if (isSameDay(date, yesterday)) {
      result =  `昨天 星期${weekDay}`;
    } else {
      result = `${month}月${day}日 星期${weekDay}`;
    }
  }

  return result;
}


export function  isSameDay(date1: Date, date2: Date): boolean {
  return date1.getFullYear() === date2.getFullYear() &&
  date1.getMonth() === date2.getMonth() &&
  date1.getDate() === date2.getDate();
}


export function getMoodColor(level: number): string {
  switch(level) {
    case 5: return '#98FB98';  // 金色，非常好的心情
    case 4: return '#9998fb98';  // 淡绿色，好心情
    case 3: return '#87CEFA';  // 淡蓝色，平静
    case 2: return '#FFA07A';  // 浅橙色，略微不好
    case 1: return '#e6f08080';  // 浅红色，不好
    case 0: return '#F08080';  // 浅灰色，中性
    case -1: return '#FFA07A'; // 深灰色，略差
    case -2: return '#F08080'; // 灰色，很差
    case -999: return '#66d3d3d3'; // 默认值
    default: return '#FFFFFF'; // 白色，无记录
  }
}


export  function formatDateToChinese(date: Date|undefined, withYear: boolean = true ): string {
  if(!date){
    return ''
  }
  const year = date.getFullYear();
  const month = date.getMonth() + 1; // getMonth() 返回 0-11
  const day = date.getDate();
  if(withYear) {
    return `${year}年${month.toString()}月${day.toString()}日`;
  }else{
    return `${month.toString()}月${day.toString()}日`;
  }
}

export  function  parseDate(dateString: string): Date {

  if (!dateString || dateString.trim() === '') {
    return null; // 返回 null 表示无效日期
  }

    let parts = dateString.match(/(\d+)/g);
    return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));

}


export  function  stringToDate(dateString: string): Date {

  if (!dateString || dateString.trim() === '') {
    return null; // 返回 null 表示无效日期
  }

  return new Date(dateString);

}


export function overDue(dueDate: Date): boolean {
  let today = new Date();
  today.setHours(0, 0, 0, 0); // 设置时间为当天的开始
  let isPastDue = dueDate.getTime() < today.getTime();
  return isPastDue
}