class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def has_cycle(head: ListNode) -> bool:
    slow = head
    fast = head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow == fast:
            return True
    
    return False


    

# debug your code below
node1 = ListNode(1)
node2 = ListNode(2)
node3 = ListNode(3)
node4 = ListNode(4)

# creates a linked list with a cycle: 1 -> 2 -> 3 -> 4 -> 2 (cycle)
node1.next = node2
node2.next = node3
node3.next = node4
node4.next = node2 

print(has_cycle(node1))
