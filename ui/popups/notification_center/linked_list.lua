-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local Node = {}
Node.__index = Node

function Node.new(n, t)
    return setmetatable({ notification = n, time = t, next = nil, prev = nil }, Node)
end

local linked_list = { mt = {} }
linked_list.__index = linked_list

local properties = {
    head = nil,
    tail = nil,
    rnode = nil,
    lnode = nil,
    distance = 0,
}

function linked_list.new(max_distance)
    properties.MAX = max_distance or 0
    return setmetatable(properties, linked_list)
end

function linked_list:append(n, t)
    local new_node = Node.new(n, t)
    if not self.head then
        self.head = new_node
        self.tail = new_node
        self.lnode = new_node
        self.rnode = new_node
        self.distance = 1
        return
    end
    new_node.prev = self.tail
    self.tail.next = new_node
    self.tail = new_node

    if self.distance == self.MAX then
        self.rnode = new_node
        self.lnode = self.lnode.next
    else
        self.distance = self.distance + 1
        self.rnode = new_node
    end
end

function linked_list:is_rnode_tail()
    return self.rnode == self.tail
end

function linked_list:retail()
    self.distance = 0
    self.rnode = self.tail
    self.lnode = self.rnode
    while self.lnode ~= self.head and self.distance < self.MAX do
        self.distance = self.distance + 1
        self.lnode = self.lnode.prev
    end
end

-- sliding happens only when already at MAX
function linked_list:rslide()
    if self.rnode ~= self.tail then
        self.lnode = self.lnode.next
        self.rnode = self.rnode.next
        return true
    end
    return false
end

-- sliding happens only when already at MAX
function linked_list:lslide()
    if self.lnode ~= self.head then
        self.lnode = self.lnode.prev
        self.rnode = self.rnode.prev
        return true
    end
    return false
end

function linked_list:delete_sequence()
    if self.lnode.prev then
        self.lnode.prev.next = self.rnode.next
    else
        self.head = self.rnode.next
    end

    if self.rnode.next then
        self.rnode.next.prev = self.lnode.prev
    else
        self.tail = self.lnode.prev
    end
end

function linked_list:clear()
    local current = self.head
    while current do
        current.notification:destroy(-1)
        current.notification = nil

        -- Move to the next node
        local next_node = current.next
        current.next = nil
        current.prev = nil
        current = next_node
    end

    -- Reset the linked list properties
    self.head = nil
    self.tail = nil
    self.rnode = nil
    self.lnode = nil
    self.distance = 0
end

-- callback for the sequence rnode -> lnode
function linked_list:apply_to(callback, ...)
    local current = self.rnode
    while current and current ~= self.lnode.prev do
        callback(self, ...)
        current = current.prev
    end
end

function linked_list.mt:__call(...)
    return linked_list.new(...)
end

return setmetatable(linked_list, linked_list.mt)
