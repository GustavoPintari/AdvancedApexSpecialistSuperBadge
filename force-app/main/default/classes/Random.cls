@isTest
public class Random {
    class RandomException extends Exception {}

    public enum CharacterSet { ALPHA, ALPHA_NUMERIC, NUMERIC, LOWER_ALPHA, UPPER_ALPHA, LOWER_ALPHA_NUMERIC, UPPER_ALPHA_NUMERIC }

    public static String generateText(Integer length)  {
        return generateString (length, CharacterSet.ALPHA);
    }

    public static String generateAlphaNumeric(Integer length) {
        return generateString (length, CharacterSet.ALPHA_NUMERIC);
    }

    public static Integer generateInteger(Integer length) {
        return Integer.valueOf(generateString(length, CharacterSet.NUMERIC));
    }

    public static Decimal generateDecimal(Integer length, Integer decimalPlaces) {
        if ((decimalPlaces == null) || (decimalPlaces < 0)) {
            decimalPlaces = 0;
        }

        if (decimalPlaces >= length) {
            throw new RandomException('Parameter "decimalPlaces" must be smaller than parameter "length".');
        }

        String decimalPlacesValue = (decimalPlaces == 0) ? '0' : generateString(decimalPlaces, CharacterSet.NUMERIC);
        String integerValue = generateString(length - decimalPlaces, CharacterSet.NUMERIC);

        return Decimal.valueOf(integerValue + '.' + decimalPlacesValue);
    }

    public static String generateString(Integer length, CharacterSet charSet) {
        if ((length == null) || (length < 1)) {
            throw new RandomException('Parameter "length" must be greater than zero.');
        }

        String chars = getCharacters(charSet);
        List<String> result = new String[length];
        Integer index = 0;

        while (index < length) {
            Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            result[index++] = chars.substring(chr, chr + 1);
        }

        return String.join(result, '');
    }

    public static String generateCNPJ() {
        List<Integer> cnpjNumbers = new Integer[14];

        for (Integer i = 0; i < 8; i++) {
            cnpjNumbers[i] = Math.round(Math.random() * 9);
        }

        cnpjNumbers[8] = 0;
        cnpjNumbers[9] = 0;
        cnpjNumbers[10] = 0;
        cnpjNumbers[11] = 1;

        cnpjNumbers[12] = calculateDigit(cnpjNumbers, 1);
        cnpjNumbers[13] = calculateDigit(cnpjNumbers, 2);

        String cnpj = '';
        for (Integer i = 0; i < 14; i++) {
            cnpj += String.valueOf(cnpjNumbers[i]);
        }

        return cnpj;
    }

    private static Integer calculateDigit(List<Integer> cnpjNumbers, Integer digit) {
        List<Integer> weights = digit == 1 ? new List<Integer>{5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2} : new List<Integer>{6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        Integer sum = 0;

        for (Integer i = 0; i < weights.size(); i++) {
            sum += cnpjNumbers[i] * weights[i];
        }

        Integer remainder =  Math.mod(sum, 11);

        return remainder < 2 ? 0 : 11 - remainder;
    }

    private static String getCharacters(CharacterSet charSet) {
        switch on charSet {
            when NUMERIC {
                return '0123456789';
            } when LOWER_ALPHA {
                return 'abcdefghijklmnopqrstuvwxyz';
            } when UPPER_ALPHA {
                return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            } when ALPHA {
                return 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            } when LOWER_ALPHA_NUMERIC {
                return '0123456789abcdefghijklmnopqrstuvwxyz';
            } when UPPER_ALPHA_NUMERIC {
                return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            } when ALPHA_NUMERIC {
                return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            } when else {
                throw new RandomException('Argument out of range valid for enum CharacterSet');
            }
        }
    }
}