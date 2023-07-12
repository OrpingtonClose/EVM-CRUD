// SPDX-License-Identifier
pragma solidity ^0.6.0;

import "./HitchensUnorderedKeySet.sol";

contract LineItems {

    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set LineItemSet;

    struct RecordStruct {
        int L_ORDERKEY;
        int L_PARTKEY;
        int L_SUPPKEY;
        int L_LINENUMBER;
        int L_QUANTITY;
        int L_EXTENDEDPRICE;
        int L_DISCOUNT;
        int L_TAX;
        string L_RETURNFLAG;
        string L_LINESTATUS;
        string L_SHIPDATE;
        string L_COMMITDATE;
        string L_RECEIPTDATE;
        string L_SHIPINSTRUCT;
        string L_SHIPMODE;
        string L_COMMENT;
    }

    mapping(bytes32 => RecordStruct) lineItems;

    //event LogNewWidget(address sender, bytes32 key, string name, bool delux, uint price);
    //event LogUpdateWidget(address sender, bytes32 key, string name, bool delux, uint price);
    //event LogRemWidget(address sender, bytes32 key);

    function newWidget(bytes32 key,         
        int L_ORDERKEY,
        int L_PARTKEY,
        int L_SUPPKEY,
        int L_LINENUMBER,
        int L_QUANTITY,
        int L_EXTENDEDPRICE,
        int L_DISCOUNT,
        int L_TAX,
        string memory L_RETURNFLAG,
        string memory L_LINESTATUS,
        string memory L_SHIPDATE,
        string memory L_COMMITDATE,
        string memory L_RECEIPTDATE,
        string memory L_SHIPINSTRUCT,
        string memory L_SHIPMODE,
        string memory L_COMMENT) public {
        LineItemSet.insert(key); // Note that this will fail automatically if the key already exists.
        RecordStruct storage w = lineItems[key];
        w.L_ORDERKEY = L_ORDERKEY;
        w.L_PARTKEY = L_PARTKEY;
        w.L_SUPPKEY = L_SUPPKEY;
        w.L_LINENUMBER = L_LINENUMBER;
        w.L_QUANTITY = L_QUANTITY;
        w.L_EXTENDEDPRICE = L_EXTENDEDPRICE;
        w.L_DISCOUNT = L_DISCOUNT;
        w.L_TAX = L_TAX;        
        w.L_RETURNFLAG = L_RETURNFLAG;
        w.L_LINESTATUS = L_LINESTATUS;
        w.L_SHIPDATE = L_SHIPDATE;
        w.L_COMMITDATE = L_COMMITDATE;
        w.L_RECEIPTDATE = L_RECEIPTDATE;
        w.L_SHIPINSTRUCT = L_SHIPINSTRUCT;
        w.L_SHIPMODE = L_SHIPMODE;
        w.L_COMMENT = L_COMMENT;
        //w.name = name;
        //w.delux = delux;
        //w.price = price;
        //emit LogNewWidget(msg.sender, key, name, delux, price);
    }
/*
    function updateWidget(bytes32 key, string memory name, bool delux, uint price) public {
        require(widgetSet.exists(key), "Can't update a widget that doesn't exist.");
        WidgetStruct storage w = widgets[key];
        w.name = name;
        w.delux = delux;
        w.price = price;
        emit LogUpdateWidget(msg.sender, key, name, delux, price);
    }

    function remWidget(bytes32 key) public {
        LineItemSet.remove(key); // Note that this will fail automatically if the key doesn't exist
        delete lineItems[key];
        //emit LogRemWidget(msg.sender, key);
    }
*/
    function getLineItem(bytes32 key) public view returns(     
        int L_ORDERKEY,
        int L_PARTKEY,
        int L_SUPPKEY,
        int L_LINENUMBER,
        int L_QUANTITY,
        int L_EXTENDEDPRICE,
        int L_DISCOUNT,
        int L_TAX,
        string memory L_RETURNFLAG,
        string memory L_LINESTATUS,
        string memory L_SHIPDATE,
        string memory L_COMMITDATE,
        string memory L_RECEIPTDATE,
        string memory L_SHIPINSTRUCT,
        string memory L_SHIPMODE,
        string memory L_COMMENT) {
        require(lineItemSet.exists(key), "Can't get a widget that doesn't exist.");
        RecordStruct storage w = lineItems[key];
        return(w.L_ORDERKEY, w.L_PARTKEY, w.L_SUPPKEY, w.L_LINENUMBER, w.L_QUANTITY, w.L_EXTENDEDPRICE,
               w.L_DISCOUNT, w.L_TAX, w.L_RETURNFLAG, w.L_LINESTATUS, w.L_SHIPDATE, w.L_COMMITDATE,
               w.L_RECEIPTDATE,w.L_SHIPINSTRUCT,w.L_SHIPMODE,w.L_COMMENT);
    }

    function getWidgetCount() public view returns(uint count) {
        return widgetSet.count();
    }

    function getWidgetAtIndex(uint index) public view returns(bytes32 key) {
        return widgetSet.keyAtIndex(index);
    }
}
