@isTest
public with sharing class TestVerifyDate {

    @isTest
    public static void testDateWithin30Days() {
        Date dateA = Date.newInstance(2023, 10, 1);
        Date dateB = Date.newInstance(2023, 10, 15);

        Date result = VerifyDate.checkDates(dateA, dateB);

        Assert.areEqual(dateB, result, 'A data retornada deve ser igual a dataB, pois está dentro de 30 dias.');
    }

    @isTest
    public static void testDateOutside30Days() {
        Date dateA = Date.newInstance(2023, 10, 1);
        Date dateB = Date.newInstance(2023, 11, 15);

        Date result = VerifyDate.checkDates(dateA, dateB);

        Date expectedDate = Date.newInstance(2023, 10, 31);
        Assert.areEqual(expectedDate, result, 'A data retornada deve ser o último dia do mês da dataA.');
    }

    @isTest
    public static void testDateBeforeDateA() {
        Date dateA = Date.newInstance(2023, 10, 1);
        Date dateB = Date.newInstance(2023, 9, 15);

        Date result = VerifyDate.checkDates(dateA, dateB);

        Date expectedDate = Date.newInstance(2023, 10, 31);
        Assert.areEqual(expectedDate, result, 'A data retornada deve ser o último dia do mês de Data1, pois a dataB é anterior.');
    }

    @isTest
    public static void testDateExactly30Days() {
        Date dateA = Date.newInstance(2023, 10, 1);
        Date dateB = Date.newInstance(2023, 10, 31); 

        Date result = VerifyDate.checkDates(dateA, dateB);

        Date expectedDate = Date.newInstance(2023, 10, 31); 
        Assert.areEqual(expectedDate, result, 'A data retornada deve ser o último dia do mês da dataA, pois a dataB é exatamente 30 dias após.');
    }
}