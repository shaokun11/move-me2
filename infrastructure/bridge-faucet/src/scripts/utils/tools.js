export function isNull(val) {
    if (typeof val === 'boolean') {
        return false;
    }
    if (typeof val === 'number') {
        return false;
    }
    if (val instanceof Array) {
        if (val.length === 0) return true;
    } else if (val instanceof Object) {
        if (JSON.stringify(val) === '{}') return true;
    } else {
        if (val === 'null' || val == null || val === 'undefined' || val === undefined || val === '') return true;
        return false;
    }
    return false;
}

export function numFT(value, minLen, maxLen, cen) {
    if (isNaN(value)) return 0;
    minLen = minLen || 4;
    maxLen = maxLen || 6;
    cen = cen || 10;
    value = Number(value);
    if (Math.abs(value) < cen) {
        return toFixeds(value, minLen);
    } else {
        return toFixeds(value, maxLen);
    }


}
/**
 * 输出语句
 */
export function trace(message, ...optionalParams) {
     console.log(message, ...optionalParams);
}
export function removeZERO(value) {
    let str = String(value);
    let id = str.indexOf(".")
    if (id >= 0) {
        while (str.slice(-1) == "0") {
            str = str.slice(0, -1)
        }
        if (str.slice(-1) == ".") {
            str = str.slice(0, -1)
        }
    }
    return str;
}


export function toFixed2Str(value) {
    let str = Number(value).toFixed(2);
    return removeZERO(str)
}

export function toFixed4Str(value) {
    let str = Number(value).toFixed(4);
    return removeZERO(str)
}

export function toFixed6Str(value) {
    let str = Number(value).toFixed(6);
    return removeZERO(str)
}

export function toFixed8Str(value) {
    let str = Number(value).toFixed(8);
    return removeZERO(str)
}

export function toFixedStrs(value, len) {
    let str = Number(value).toFixed(len);
    return removeZERO(str)
}
export function toFixedChange(value, len) {
    len = len || 4
    if (Number(value) > 1) {
        return toFixeds(value, len)
    } else if (Number(value) > 0.01) {
        return toFixeds(value, 4)
    } else if (Number(value) > 0.0001) {
        return toFixeds(value, 6)
    } else if (Number(value) > 0.000001) {
        return toFixeds(value, 8)
    } else if (Number(value) > 0.00000001) {
        return toFixeds(value, 10)
    } else if (Number(value) > 0.0000000001) {
        return toFixeds(value, 12)
    } else if (Number(value) > 0.000000000001) {
        return toFixeds(value, 14)
    } else if (Number(value) > 0.00000000000001) {
        return toFixeds(value, 16)
    }
}
/**
 * 保留2位有效数据
 * @param value （string/Number）
 */
export function toFixed2(value) {

    if (Math.abs(Number(value)) < 0.01) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 2));
    value = a * Math.pow(10, -2)
    return parseFloat(Number(Number(value).toFixed(2)))
}


/**
 * 保留4位有效数据
 * @param value （string/Number）
 */
export function toFixed4(value) {

    if (Math.abs(Number(value)) < 0.0001) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 4));
    value = a * Math.pow(10, -4)
    return parseFloat(Number(Number(value).toFixed(4)))
}

/**
 * 保留6位有效数据
 * @param value （string/Number）
 */
export function toFixed6(value) {
    if (Math.abs(Number(value)) < 0.000001) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 6));
    value = a * Math.pow(10, -6)
    return parseFloat(Number(Number(value).toFixed(6)))
}

/**
 * 保留8位有效数据
 * @param value （string/Number）
 */
export function toFixed8(value) {
    if (Math.abs(Number(value)) < 0.00000001) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 8));
    value = a * Math.pow(10, -8)
    return parseFloat(Number(Number(value).toFixed(8)))
}

/**
 * 保留12位有效数据
 * @param value （string/Number）
 */
export function toFixed12(value) {
    if (Math.abs(Number(value)) < 0.000000000001) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 12));
    value = a * Math.pow(10, -12)
    return parseFloat(Number(Number(value).toFixed(12)))
}

/**
 * 保留16位有效数据
 * @param value （string/Number）
 */
export function toFixed16(value) {
    if (Math.abs(Number(value)) < 0.0000000000000001) return 0;
    let a = Math.floor(Number(value) * Math.pow(10, 16));
    value = a * Math.pow(10, -16)
    return parseFloat(Number(Number(value).toFixed(16)))
}

export function toFixeds(value, num) {
    if (!num || num < 2) num = 2;
    if (Math.abs(Number(value)) < Math.pow(10, -num)) return 0;

    let a = Math.floor(Number(value) * Math.pow(10, num));
    value = a * Math.pow(10, -num)
    return parseFloat(Number(Number(value).toFixed(num)))
}

export function resetStringKMG(value) {
    // trace("resetString=",value,value=="",value==0)
    if (value == "") return "0";
    if (value == 0) return "0.00";
    if (isNaN(value)) return "0.00"
    let a = "";
    let b = ""
    if (Number(value) < 0) {
        value = Math.abs(Number(value));
        a = "-";
    }

    value = Number(value)
    if (value >= 1000 * 1000 * 1000) {
        b = toFixed2(value / (1000 * 1000 * 1000)) + "b"
    } else if (value >= 1000 * 1000) {
        b = toFixed2(value / (1000 * 1000)) + "m"
    } else if (value >= 1000) {
        b = toFixed2(value / (1000)) + "k"
    } else {
        b = toFixed2(value);
    }

    return a + b;
}

export function resetStringKMG2(value) {
    // trace("resetString=",value,value=="",value==0)
    if (value == "") return "0.00";
    if (value == 0) return "0.00";
    if (isNaN(value)) return "0.00"
    let a = "";
    let b = ""
    if (Number(value) < 0) {
        value = Math.abs(Number(value));
        a = "-";
    }
    value = Math.abs(Number(value))

    if (value >= 1000 * 1000 * 1000) {
        b = (value / (1000 * 1000 * 1000)).toFixed(2) + "b"
    } else if (value >= 1000 * 1000) {
        b = (value / (1000 * 1000)).toFixed(2) + "m"
    } else if (value >= 1000) {
        b = (value / (1000)).toFixed(2) + "k"
    } else {
        b = (value).toFixed(2);
    }

    return a + b;
}

export async function sleep(time) {
    return new Promise(function (resolve, reject) {
        setTimeout(resolve, time);
    });
}

export function toThousands(num) {
    if (Math.abs(Number(num)) < 1000) return num;
    num = parseInt(Number(num));
    num = (num || 0).toString();
    let re = /\d{3}$/;
    let result = '';
    while (re.test(num)) {
        result = RegExp.lastMatch + result;
        if (num !== RegExp.lastMatch) {
            result = ',' + result;
            num = RegExp.leftContext;
        } else {
            num = '';
            break;
        }
    }
    if (num) {
        result = num + result;
    }
    return result;
}

/**
 * 剩余时间毫秒
 * @param lefttime
 * @returns {string}   01:25:22
 */
export function hkGetTime(lefttime,fstr=':') {
    if (('' + lefttime).length === 10) {
        lefttime = parseInt(lefttime) * 1000
    } 
    // var leftd = Math.floor(lefttime / (1000 * 60 * 60 * 24)),  //计算天数
    var lefth = Math.floor(lefttime / (1000 * 60 * 60) % 24),  //计算小时数
    leftm = Math.floor(lefttime / (1000 * 60) % 60), //计算分钟数
    lefts = Math.floor(lefttime / 1000 % 60);  //计算秒数
    if(lefth.toString().length==1) lefth = '0'+lefth;
    if(leftm.toString().length==1) leftm = '0'+leftm;
    if(lefts.toString().length==1) lefts = '0'+lefts;
    return lefth + fstr + leftm + fstr + lefts;  //返回倒计时的字符串
}

//替换字符串中间字符为'.'
export function replaceStr(str,startlen=4,endLen=4,replaceStr='...') {
   const a = str.slice(0,startlen);
   const b = str.slice(str.length-endLen);
   return a + replaceStr + b;
}