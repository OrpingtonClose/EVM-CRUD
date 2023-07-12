// SPDX-License-Identifier
pragma solidity ^0.6.0;

import "./UintSet.sol";

contract Nation {

    using UintSet for UintSet.Set;
    UintSet.Set set;

    struct RecordStruct {
        string N_NAME;
        uint N_REGIONKEY;
        string N_COMMENT;
    }

    mapping(uint => RecordStruct) things;

    function newNation(uint N_NATIONKEY, string memory N_NAME, uint N_REGIONKEY, string memory N_COMMENT) public {
        set.insert(N_NATIONKEY); // Note that this will fail automatically if the key already exists.
        RecordStruct storage w = things[N_NATIONKEY];
        w.N_NAME = N_NAME;
        w.N_REGIONKEY = N_REGIONKEY;
        w.N_COMMENT = N_COMMENT;
    }

    function updateWidget(uint N_NATIONKEY, string memory N_NAME, uint N_REGIONKEY, string memory N_COMMENT) public {
        require(set.exists(N_NATIONKEY), "Can't update a widget that doesn't exist.");
        RecordStruct storage w = things[N_NATIONKEY];
        w.N_NAME = N_NAME;
        w.N_REGIONKEY = N_REGIONKEY;
        w.N_COMMENT = N_COMMENT;
    }

    function remWidget(uint N_NATIONKEY) public {
        set.remove(N_NATIONKEY); // Note that this will fail automatically if the key doesn't exist
        delete things[N_NATIONKEY];
    }

    function getWidget(uint N_NATIONKEY) public view returns(string memory N_NAME, uint N_REGIONKEY, string memory N_COMMENT) {
        require(set.exists(N_NATIONKEY), "Can't get a widget that doesn't exist.");
        RecordStruct storage w = things[N_NATIONKEY];
        return(w.N_NAME, w.N_REGIONKEY, w.N_COMMENT);
    }

    function getCount() public view returns(uint count) {
        return set.count();
    }

    function getWidgetAtIndex(uint index) public view returns(uint key) {
        return set.keyAtIndex(index);
    }
}
