/**
 * @name orderTrigger
 * @description
**/

trigger orderTrigger on Order (after update)
{
    List<Order> updatedOrders = Trigger.Old;
    List<Order> ordersToUpdate = Trigger.New;

    OrderHelper.AfterUpdate(ordersToUpdate, updatedOrders);
}