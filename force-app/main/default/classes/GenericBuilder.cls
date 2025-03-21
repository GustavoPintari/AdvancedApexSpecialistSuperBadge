/**
 * @description       : Classe builder para objetos genéricos
 * @author            : Thayna Peres (thayna@visumdigital.com)
 * @last modified on  : 25-02-2025
 * @last modified by  : Thayna Peres (thayna@visumdigital.com)
**/

public with sharing abstract class GenericBuilder {
    protected SObject record;
    protected Map<String, Schema.SObjectField> mObjectFields = new Map<String, Schema.SObjectField>();

    public GenericBuilder(SObject record) {
        this.record = record;
        if(mObjectFields.isEmpty()) {
            mObjectFields = SchemaUtils.getSObjectFieldMap(this.record.getSObjectType().getDescribe().getName());
        }
    }

    public GenericBuilder assign(String field, Object value) {
        if(!mObjectFields.containsKey(field)) {
            throw new IllegalArgumentException('Object ' + this.record.getSObjectType().getDescribe().getName() + ' does not have the ' + field + ' field.');
        }

        this.record.put(field, value);
        return this;
    }

    public SObject build() {
        return this.record;
    }
}