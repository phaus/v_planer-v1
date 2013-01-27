Date.prototype.toFormattedString = function(include_time) {
  var str = this.getFullYear() + '-' + Date.padded2(this.getMonth() + 1) + '-' + Date.padded2(this.getDate());
  return str;
}
