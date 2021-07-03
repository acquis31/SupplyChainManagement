// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {
    //Creating structure for the S_item
    struct S_Item {
        Item _item;
        ItemManager.SupplyChainSteps _step;
        string _identifier;
    }
    mapping(uint256 => S_Item) public items;
    uint256 index;

    enum SupplyChainSteps {
        Created,
        Paid,
        Delivered
    }

    //Defining event
    event SupplyChainStep(uint256 _itemIndex, uint256 _step, address _address);

    //function to create Item
    function createItem(string memory _identifier, uint256 _priceInWei)
        public
        onlyOwner
    {
        Item item = new Item(this, _priceInWei, index);
        items[index]._item = item;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;
        emit SupplyChainStep(index, uint256(items[index]._step), address(item));
        index++;
    }

    //function to trigger Payment
    function triggerPayment(uint256 _index) public payable {
        Item item = items[_index]._item;
        require(
            address(item) == msg.sender,
            "Only items are allowed to update themselves"
        );
        require(item.priceInWei() == msg.value, "Not fully paid yet");
        require(
            items[index]._step == SupplyChainSteps.Created,
            "Item is further in the supply chain"
        );
        items[_index]._step = SupplyChainSteps.Paid;
        emit SupplyChainStep(
            _index,
            uint256(items[_index]._step),
            address(item)
        );
    }

    //function triggerDelivery
    function triggerDelivery(uint256 _index) public onlyOwner {
        require(
            items[_index]._step == SupplyChainSteps.Paid,
            "Item is further in the supply chain"
        );
        items[_index]._step = SupplyChainSteps.Delivered;
        emit SupplyChainStep(
            _index,
            uint256(items[_index]._step),
            address(items[_index]._item)
        );
    }
}
