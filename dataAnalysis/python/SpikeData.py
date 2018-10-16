"""
@file     SpikeData.py 
@author   Jewel Lee (jewel87@uw.edu)
@date     5/5/2018

@brief    Spike and Avalanche class implementation 

"""
import numpy as np
GRID = 100

# -----------------------------------------------------------------------------
# CLASS: Spike()
# each Spike is a node contains it's spiking timestep (ts) and neuron ID
# -----------------------------------------------------------------------------
class Spike(object):
    def __init__(self, ts, i):
        self.ts = ts
        self.id = i
        self.next = None  # the pointer initially points to nothing
        self.prev = None  # the pointer initially points to nothing

    def x(self):
        y = np.floor_divide((self.id - 1), GRID) + 1
        x = self.id - (GRID*y) + GRID
        return x

    def y(self):
        y = np.floor_divide((self.id - 1), GRID) + 1
        return y


# -----------------------------------------------------------------------------
# CLASS: Avalanche()
# each Avalanche is a doubly linked list
# -----------------------------------------------------------------------------
class Avalanche(object):

    def __init__(self):
        self.head = None
        self.tail = None
        self.size = 0
        return

    def __len__(self):
        return self.size

    def __del__(self):
        node = self.head
        while node is not None:
            curr = node.next
            del node
            node = curr
        del self
        return None

    def is_empty(self):
        return len(self) == 0

    # -----------------------------------------------------------------------------
    # create a new node and add it to this avalanche
    # -----------------------------------------------------------------------------
    def add_node(self, ts, i):
        new_node = Spike(ts, i)
        # if no head, set new node as head
        if self.head is None:
            self.head = new_node
            self.tail = new_node
        else:
            curr_node = self.head
            # if next not none (tail) continue traversing
            while curr_node.next is not None:
                curr_node = curr_node.next
            # end while
            # if tail, add to end
            curr_node.next = new_node
            # set prev pointer to current node
            new_node.prev = curr_node
            # set new tail to new node
            self.tail = new_node
        # increment size
        self.size = self.size + 1
        return

    # -----------------------------------------------------------------------------
    # insert an existed node to be the tail of this avalanche
    # -----------------------------------------------------------------------------
    def __insert_tail(self, new_node):
        old_tail = self.tail
        old_tail.next = new_node
        new_node.prev = old_tail
        new_node.next = None
        self.tail = new_node
        # increment size
        self.size = self.size + 1
        return

    # -----------------------------------------------------------------------------
    # insert an existed node to be the head of this avalanche
    # -----------------------------------------------------------------------------
    def __insert_head(self, new_node):
        old_head = self.head
        old_head.prev = new_node
        new_node.next = old_head
        new_node.prev = None
        self.head = new_node
        # increment size
        self.size = self.size + 1
        return

    # -----------------------------------------------------------------------------
    # insert an existed node into the middle of this avalanche
    # -----------------------------------------------------------------------------
    def __insert(self, new_node):
        curr_node = self.head
        while curr_node.ts < new_node.ts:
            curr_node = curr_node.next
        prev_node = curr_node.prev
        prev_node.next = new_node
        new_node.next = curr_node
        curr_node.prev = new_node
        new_node.prev = prev_node

        # increment size
        self.size = self.size + 1
        return

    # -----------------------------------------------------------------------------
    #
    # -----------------------------------------------------------------------------
    def remove(self, curr_node):
        if curr_node is self.head:
            next_node = self.head.next
            self.head = next_node
            next_node.prev = None

        elif curr_node is self.tail:
            prev_node = self.tail.prev
            self.tail = prev_node
            prev_node.next = None
        else:
            prev_node = curr_node.prev
            next_node = curr_node.next
            prev_node.next = next_node
            next_node.prev = prev_node
        # endif
        # decrement size
        self.size = self.size - 1
        del curr_node
        return

    # -----------------------------------------------------------------------------
    # merge two avalanches into one
    # -----------------------------------------------------------------------------
    def merge(self, aval):
        # print("In merge: self:")
        # self.display()
        # print("          aval:")
        # aval.display()
        node = aval.head
        while node is not None:
            dummy_head = node.next
            if node.ts <= self.head.ts:
                self.__insert_head(node)
            elif node.ts >= self.tail.ts:
                self.__insert_tail(node)
            else:
                self.__insert(node)
            node = dummy_head
        del aval

    # -----------------------------------------------------------------------------
    # display avalanche list in tuples (ts, id)
    # -----------------------------------------------------------------------------
    def display(self):
        current_node = self.head
        while current_node is not None:
            print(current_node.ts, current_node.id)
            current_node = current_node.next
        return