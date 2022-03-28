bool compareDateTime(dateOriginal, dateNew){
  List listDate = [];
  listDate.add(dateOriginal);
  listDate.add(dateNew);
  listDate.sort((a,b)=> a.compareTo(b));
  if(listDate[0] == dateOriginal && listDate[0] != listDate[1]){
    return false; //old date
  }else if(listDate[1] == dateOriginal && listDate[0] != listDate[1]){
    return true; //new date
  }
}