/**
 * @description       : Classe utilitária para facilitar o uso da classe Schema
 * @author            : Leonardo Nowacki (leonardo.nowacki@visumdigital.com)
 * @group             : 
 * @last modified on  : 19-02-2025
 * @last modified by  : Gustavo Pintari (gustavo@visumdigital.com)
**/
public with sharing class SchemaUtils {

	private static Map<String, Schema.SObjectType> mGlobalDescribeInstance; 

	@TestVisible
	private class SchemaUtilException extends Exception {}

	/**
	* @description          		: Retorna o ID do tipo de registro a partir do SObject e do nome de desenvolvedor
	* @param describeResult		  	: Schema.DescribeSObjectResult do SObject.
	* @param developerName 			: O nome de desenvolvedor do tipo de registro (DeveloperName).
	* @return			    		: ID do tipo de registro.
	**/
	public static Id getRecordTypeId(Schema.DescribeSObjectResult describeResult, String developerName) {
		Schema.RecordTypeInfo recordTypeInfo = describeResult.getRecordTypeInfosByDeveloperName().get(developerName);

		if (recordTypeInfo == null) {
			String errorPattern = 'RecordType {0} not found on {1} sObject';
			String errorMessage = String.format(errorPattern, new List<String>{developerName, describeResult.getName()});

			throw new SchemaUtilException(errorMessage);
		}

		return recordTypeInfo.getRecordTypeId();
	}

	/**
	* @description					: Retorna um mapa dos campos para o SObject especificado.
	* @param objectApiName 	    	: O nome de API do SObject.
	* @return 						: Um mapa dos campos para o SObject especificado.
	* @throws SchemaUtilException 	: Se o SObject não for encontrado.
	*/
	public static Map<String, Schema.SObjectField> getSObjectFieldMap(String objectApiName) {
		return getSObjectType(objectApiName).getDescribe().fields.getMap();
	}

	/**
	* @description					: Gera um ID fictício para um determinado SObject e índice.
	* @param describeResult 		: Schema.DescribeSObjectResult do SObject.
	* @param index 					: O índice a ser usado no ID gerado.
	* @return 						: O ID gerado.
	*/
	public static Id generateMockId(Schema.DescribeSObjectResult describeResult, Integer index) {
		Integer idLength = 18;
		String convertedIndex = String.valueOf(index);
		String prefix = describeResult.getKeyPrefix();

		return prefix.rightPad(idLength - prefix.length() - convertedIndex.length(), '0') + convertedIndex;
	}

	/**
	* @description					: Verifica se o ID fornecido pertence ao tipo de objeto especificado.
	* @param id 					: O ID a ser validado.
	* @param objectApiName 			: O nome de API do SObject.
	* @return 						: true se o ID corresponder ao tipo especificado; caso contrário, false.
	* @throws SchemaUtilException 	: Se o SObject não for encontrado.
	*/
	public static Boolean isIdOfType(Id id, String objectApiName) {
		return id.getSObjectType() == getSObjectType(objectApiName);
	}

	/**
	* @description					: Retorna um mapa de tipos de registro de um SObject.
	* @param objectApiName 			: O nome de API do SObject.
	* @return 						: Um mapa onde a chave é o ID do tipo de registro e o valor seu Nome de Desenvolvedor.
	* @throws SchemaUtilException 	: Se o SObject não for encontrado.
	*/
	public static Map<Id, String> getMapOfObjectRecordTypeDeveloperNameByRecordTypeId(String objectApiName) {
		Schema.DescribeSObjectResult describeResult = getSObjectType(objectApiName).getDescribe();
		
		Map<Id, Schema.RecordTypeInfo> mRecordTypeInfoByRecordTypeId = describeResult.getRecordTypeInfosById();

		Map<Id, String> mRecordTypeDeveloperNameByRecordTypeId = new Map<Id, String>();
		
		for (Id recordTypeId : mRecordTypeInfoByRecordTypeId.keySet()) {
			mRecordTypeDeveloperNameByRecordTypeId.put(recordTypeId, mRecordTypeInfoByRecordTypeId.get(recordTypeId).getDeveloperName());
		}
		
		return mRecordTypeDeveloperNameByRecordTypeId;
    }

	/**
	* @description					: Retorna o nome de API do SObject.
	* @param objectApiName 			: O nome de API do SObject.
	* @return 						: O nome de API do SObject associado ao registro. Por exemplo, "Account" para registros do objeto Account.
	*/
	public static String getSObjectName(SObject record) {
        return record.getSObjectType().getDescribe().getName();
    }

	/**
	* @description					: Verifica se o SObject é ou não customizado.
	* @param objectApiName 			: O nome de API do SObject.
	* @return 						: true se o SObject for customizado, caso contrário, false.
	* @throws SchemaUtilException 	: Se o SObject não for encontrado.
	*/
	public static Boolean isCustomSObject(String objectApiName) {
        return getSObjectType(objectApiName).getDescribe().isCustom();
    }

	/**
	* @description					: Retorna o Schema.SObjectType de um SObject
	* @param objectApiName 			: O nome de API do SObject.
	* @return 						: Retorna o Schema.SObjectType de um SObject, validando se este existe ou não na organização.
	* @throws SchemaUtilException 	: Se o SObject não for encontrado.
	*/
	public static Schema.SObjectType getSObjectType(String objectApiName) {
		Map<String, Schema.SObjectType> mGlobalDescribe = getGlobalDescribeInstance();
	
		if (!mGlobalDescribe.containsKey(objectApiName)){
			throw new SchemaUtilException('SObject not found');
		} 

		return mGlobalDescribe.get(objectApiName);
	}

	/**
	* @description					: Controla a instancia do mapa mGlobalDescribeInstance, evitando chamadas repetidas ao método Schema.getGlobalDescribe().
	* @return 						: Um mapa onde a chave é o nome de API de todos os objetos da organização pelo seu Schema.SObjectType.
	*/
	public static Map<String, Schema.SObjectType> getGlobalDescribeInstance() {
        if (mGlobalDescribeInstance == null) {
            mGlobalDescribeInstance = Schema.getGlobalDescribe();
        }
        
        return mGlobalDescribeInstance;
    }
}