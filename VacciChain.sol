pragma solidity ^ 0.4.0;
contract VacciChain {
    
	uint constant internal UINT_MAX = ~uint(0);
	
	uint public temp;
	
	uint public temp_update_date;
	
	TempRanges public tempRange = TempRanges(2,8);
	
	Vial[] public Vials;
	
	Batch[] public Batches;
	
	Fridge_temprature [] public Fridges_Temperature;
	
	uint[] batch_ids;
	
	uint[] fridge_ids;
	
	uint[] fridge_temp_ranges;
	
	uint[] vacci_types;
	
	uint[] batch_ids_vacci_types;

	//----structs----\\

	//vial struct definition
	struct Vial {
		bool used;
		bool fault;
		uint batchID;
		uint fridgeID;
		uint vialID;
		uint user_id;
	}

	//batch struct definition
	struct Batch {
	    uint batchID;
		string info;
		uint temp;
		uint vacType;
		uint recieveDate;
		uint expireDate;
		bool fault;
		uint user_id;
		uint updated_at;
		uint fridgeID;
	}
	
	struct Fridge_temprature {
	    uint fridgeID;
	    uint temp;
	}

	//TempRanges struct definition
	struct TempRanges {
		uint min;
		uint max;
	}


	//--Batch stuff--\\

	function addBatch(uint _batch_id, string _info, uint _temp , uint _vtype, uint _expireDate, bool _fault, uint _user_id, uint _fridgeID) {
	    if(_temp >= tempRange.max || _temp <= tempRange.min){
	            _fault = true;
	    }
	    if(_expireDate <= now){
	            _fault = true;
	    }
		Batches.push(Batch( _batch_id, _info, _temp ,_vtype, now, _expireDate , _fault, _user_id, now, _fridgeID));
		Fridges_Temperature.push(Fridge_temprature(_fridgeID, _temp));
		fridge_ids.push(_fridgeID);
	}

	// Find Batch Using ID
	function find_batch_using_id(uint _batchid) returns(uint, string, uint, uint, uint, uint,bool, uint, uint, uint){
		for (uint i = 0; i <= Batches.length - 1; i++) {
			if (Batches[i].batchID == _batchid) {
			  return (Batches[i].batchID,Batches[i].info,Batches[i].temp,Batches[i].vacType,Batches[i].recieveDate, Batches[i].expireDate,Batches[i].fault,Batches[i].user_id,Batches[i].updated_at,Batches[i].fridgeID);
			}
		}
	}
	// Check if Batch Exists
	function batch_exists(uint _batchid) returns (bool){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			if (Batches[i].batchID == _batchid) {
			  return false;
			}
		}
		return true;
	}
	
	// Find Batch UsingIDVacci Type Id
	function find_batch_using_vaccitypeid(uint _vacitype_id) returns(uint []){
		for (uint i = 0; i <= Batches.length - 1; i++) {
			if (Batches[i].vacType == _vacitype_id) {
			  batch_ids_vacci_types.push(Batches[i].batchID);
			}
		}
		return batch_ids_vacci_types;
	}
	
	// Find Fridge Temperature Histroy
	function find_fridge_temp_history_using_id(uint _fridgid) returns(uint []){
		for (uint i = 0; i <= Fridges_Temperature.length - 1; i++) {
			if (Fridges_Temperature[i].fridgeID == _fridgid) {
			    fridge_temp_ranges.push(Fridges_Temperature[i].temp);
			}
		}
		return fridge_temp_ranges;
	}
	
	// Return All Fridge Ids
	
	function all_fridges() returns (uint []){
		return fridge_ids;
	}
	
	// Return All Batche Ids
	
	function all_batches() returns (uint []){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			  batch_ids.push(Batches[i].batchID);
		}
		return batch_ids;
	}
	
	// Return All Vaccination Types
	function all_vacci_types() returns (uint []){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			  vacci_types.push(Batches[i].vacType);
		}
		return vacci_types;
	}

	//Run Batch Expiry Test
	
	function RunBatch_ExpiryTest(uint _batch_id) returns (bool){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			if(Batches[i].batchID == _batch_id){
			    if (Batches[i].expireDate <= now) {
			        Batches[i].fault = true;
			        SubmitbatchFault(_batch_id);
			        return true;
			    }
			}
		}
		return false;
	}
	
	// Submit Batch Fault

	function SubmitbatchFault(uint _batch) {
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].batchID == _batch) {
				Vials[i].fault = true;
			}
		}
	}
	
		
	//--Vaccine stuff--\\
	
    //Add Vial
	function addVial(uint _batch, uint _fridgeID, uint _vialNo, uint _user_id) {
	    bool batch_fault = return_batch_fault_status(_batch);
	    if(batch_fault){
	        Vials.push(Vial(false, true, _batch, _fridgeID, _vialNo, _user_id));
	    }else{
	        Vials.push(Vial(false, false, _batch, _fridgeID, _vialNo, _user_id));
	    }
    }
	//Add Multiple Vial
	function addVials(uint _batch, uint _fridgeID, uint _vialNoStart, uint _vialNoEnd, uint _user_id) {
		for (uint i = _vialNoStart ; i <= _vialNoEnd; i++) {
			addVial(_batch, _fridgeID, i, _user_id);
		}
	}
	
	//Find Vial
	function findVial(uint _vID) returns(uint) {
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].vialID == _vID) {
				return i;
			}
		}
	}
	//Check if vial has a valid ID
	function if_new_vial_has_valid_id(uint _batch_id, uint start_id, uint end_id) returns (bool){
	    for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].batchID == _batch_id) {
			    for (uint j = start_id; j < end_id; j++){
			        if(Vials[i].vialID == j){
			         return false;
			        }
			    }
			}
		}
		
		return true;
	}

    // If Vial Exists
	function VialIDExist(uint _vID) returns(bool) {
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].vialID == _vID) {
				return true;
			}
		}
		return false;
	}

    // Mark Vial Fault
	function markVialFault(uint _vial) {
		if (VialIDExist(_vial)) {
			Vials[findVial(_vial)].fault = true;
		}
	}
	
	//----Mark Used Vial----\\
	function useVial(uint _vial,uint _batch_id) {
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].vialID == _vial && Vials[i].batchID == _batch_id) {
			    Vials[i].used = true;
			}
		}
	}


    //---- Find   Vial using Id----\\
	function findVialusingID(uint _Vialid,uint _batch_id) returns(bool, bool, uint, uint, uint,uint){
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].vialID == _Vialid && Vials[i].batchID == _batch_id) {
				return (Vials[i].used,Vials[i].fault,Vials[i].batchID,Vials[i].fridgeID,Vials[i].vialID,Vials[i].user_id);
			}
		}
	}
	

    //---- Find Immediate Valid Vial using vacci Type----\\
	function findValidVial(uint _vacType) returns(bool, bool, uint, uint, uint,uint,uint){
		for (uint i = 0; i <= Batches.length - 1; i++) {
			if (Batches[i].vacType == _vacType) {
				for (uint j = 0; j < Vials.length; j++) {
					if (Vials[j].batchID == Batches[i].batchID && Vials[j].used ==
					false && Vials[j].fault == false) {
					return (Vials[j].used,Vials[j].fault,Vials[j].batchID,Vials[j].fridgeID,Vials[j].vialID,Vials[i].user_id,_vacType);
					}
				}
			}
		}
	}

    // Search Immediate Valid Vial Using Batch ID
	function findValidVialFromBatch(uint _batch) returns(bool, bool, uint, uint, uint, uint){
		for (uint i = 0; i < Vials.length; i++) {
			if (Vials[i].batchID == _batch && 
			Vials[i].used == false && Vials[i].fault == false) {
			    return (Vials[i].used,Vials[i].fault,Vials[i].batchID,Vials[i].fridgeID,Vials[i].vialID,Vials[i].user_id);
			}
		}
	}
	
	//---- Record Temp----\\
	function record_temp(uint _temp, uint _fridgeID) returns (bool){
		temp = _temp;
		temp_update_date = now;
		Fridges_Temperature.push(Fridge_temprature(_fridgeID, _temp));
		for (uint i = 0; i <= Batches.length - 1; i++) {
		    Batches[i].temp = _temp;
			if(Batches[i].fridgeID == _fridgeID){
			    if (temp >= tempRange.max || temp <= tempRange.min) {
			            Batches[i].fault = true;
			            SubmitbatchFault(Batches[i].batchID);
			        return true;
			    }
			}
		}
	    return false;
	}
	
	// Return Batch Fault Status
	function return_batch_fault_status(uint _batch_id) returns (bool){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			if(Batches[i].batchID == _batch_id && Batches[i].fault == true){
			        return true;
			}
		}
		return false;
	}
	
	// Return Batch Fault Status Based on Fridge ID
	function return_batch_fault_status_on_fridge(uint _fridgeID) returns (bool){
	    for (uint i = 0; i <= Batches.length - 1; i++) {
			if(Batches[i].fridgeID == _fridgeID && Batches[i].fault == true){
			    return true;
			}
		}
	    return false;
	}

}

