@isTest
public with sharing class TriggerHandlerTest {
    
    private static String lastMethodCalled;
    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
    private static TriggerHandlerTest.TestHandler handler;

    static {
        handler = new TriggerHandlerTest.TestHandler();
        handler.isTriggerExecuting = true;
    }

    @isTest
    public static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        Assert.areEqual('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    public static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        Assert.areEqual('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    public static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        Assert.areEqual('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    public static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        Assert.areEqual('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    public static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        Assert.areEqual('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    public static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        Assert.areEqual('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    public static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        Assert.areEqual('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }

    @isTest 
    public static void testNonTriggerContext() {
        try {
            handler.run();
            Assert.isFalse(false, 'the handler ran but should have thrown');
        } catch(TriggerHandler.TriggerHandlerException te) {
            Assert.areEqual(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
        } catch(Exception e) {
            Assert.isFalse(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @isTest
    public static void testBypassAPI() {
        afterUpdateMode();

        TriggerHandler.bypass('TestHandler');
        handler.run();
        Assert.areEqual(null, lastMethodCalled, 'last method should be null when bypassed');
        Assert.areEqual(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        TriggerHandler.clearBypass('TestHandler');
        handler.run();
        Assert.areEqual('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        Assert.areEqual(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        TriggerHandler.bypass('TestHandler');
        handler.run();
        Assert.areEqual(null, lastMethodCalled, 'last method should be null when bypassed');
        Assert.areEqual(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        TriggerHandler.clearAllBypasses();
        handler.run();
        Assert.areEqual('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        Assert.areEqual(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
    }


    @isTest
    public static void testLoopCount() {
        beforeInsertMode();
        
        handler.setMaxLoopCount(2);

        handler.run();
        handler.run();

        resetTest();

        try {
            handler.run();
            Assert.isFalse(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
        } catch(TriggerHandler.TriggerHandlerException te) {
            Assert.areEqual(null, lastMethodCalled, 'last method should be null');
        } catch(Exception e) {  
            Assert.isFalse(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }

        resetTest();

        handler.clearMaxLoopCount();

        try {
        handler.run();
            Assert.areEqual('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
        } catch(TriggerHandler.TriggerHandlerException te) {
            Assert.isFalse(false, 'running the handler after clearing the loop count should not throw');
        } catch(Exception e) {  
            Assert.isFalse(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @isTest
    public static void testLoopCountClass() {
        TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
        Assert.areEqual(5, lc.getMax(), 'max should be five on init');
        Assert.areEqual(0, lc.getCount(), 'count should be zero on init');

        lc.increment();
        Assert.areEqual(1, lc.getCount(), 'count should be 1');
        Assert.areEqual(false, lc.exceeded(), 'should not be exceeded with count of 1');

        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        Assert.areEqual(5, lc.getCount(), 'count should be 5');
        Assert.areEqual(false, lc.exceeded(), 'should not be exceeded with count of 5');

        lc.increment();
        Assert.areEqual(6, lc.getCount(), 'count should be 6');
        Assert.areEqual(true, lc.exceeded(), 'should not be exceeded with count of 6');
    }

    @isTest 
    public static void testGetHandlerName() {
        Assert.areEqual('TestHandler', handler.getHandlerName(), 'handler name should match class name');
    }
    
    @isTest
    public static void testVirtualMethods() {
        TriggerHandler triggerHandler = new TriggerHandler();
        triggerHandler.beforeInsert();
        triggerHandler.beforeUpdate();
        triggerHandler.beforeDelete();
        triggerHandler.afterInsert();
        triggerHandler.afterUpdate();
        triggerHandler.afterDelete();
        triggerHandler.afterUndelete();

        Assert.isNotNull(triggerHandler, 'not null');
    }

    private static void resetTest() {
        lastMethodCalled = null;
    }

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }

    private class TestHandler extends TriggerHandler {
        public override void beforeInsert() {
            TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
        }

        public override void  beforeUpdate() {
            TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            TriggerHandlerTest.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            TriggerHandlerTest.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            TriggerHandlerTest.lastMethodCalled = 'afterUndelete';
        }
    }
}