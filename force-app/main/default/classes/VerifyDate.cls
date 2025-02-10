public with sharing class VerifyDate {


    // recebe duas datas -> A e B

    // Se data B < A retorna FALSO, se nao data A ganha mais 30 dias. se a data B for maior ou igual retorna falso, se nao retorna true. 
    public static Date checkDates(Date date1, Date date2) {
        if (dateWithin30Days(date1, date2)) {
            return date2;
        } else {
            return setEndOfMonthDate(date1);
        }
    }

    private static Boolean dateWithin30Days(Date date1, Date date2) {
        //check for date2 being in the past
        if (date2 < date1) { 
            return false; 
        }

        Date date30Days = date1.addDays(30); 

        if (date2 >= date30Days) { 
            return false; 
        } else { 
            return true; 
        }
    }

    private static Date setEndOfMonthDate(Date date1) {
        Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
        Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);

        return lastDay;
    }
}