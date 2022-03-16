using System;
using System.Collections.Generic;
using System.Text;
using PAT.Common.Classes.Expressions.ExpressionClass;

//the namespace must be PAT.Lib, the class and method names can be arbitrary
namespace PAT.Lib
{	
	public class Vial : ExpressionValue
    {
    	public int  id;
    	public int  vaccine_type;
    	public bool faulted;
    	
    	// Required
    	public Vial()
    	{
    		id = -1;
    		vaccine_type = -1;
    		faulted = false;
    	}
    	
    	// Required
    	public Vial(int new_id, int new_vaccine_type, bool new_faulted)
    	{
    		id = new_id;
    		vaccine_type = new_vaccine_type;
    		faulted = new_faulted;    		
    	}
    	
        // Required
        public override string ToString()
        {
            return "[Vial #" + id.ToString() + "][Type: " + vaccine_type.ToString() + "][Fault: " + faulted.ToString() + "]";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new Vial(id, vaccine_type, faulted);
        }

        // Required
        public override string ExpressionID
        {
            get {return "V"+id.ToString(); }
        }

    }
    
    public class Batch : ExpressionValue
    {
    	public int id;
    	public List<Vial> vials;
    	public List<int> temperature_history;
    	public bool faulted;
    	
    	// Required
    	public Batch()
    	{
    		id = -1;
    		vials = new List<Vial>();
    		temperature_history = new List<int>();
    		faulted = false;
    	}
    	
    	// Required
    	public Batch(int new_id)
    	{
    		id = new_id;
    		vials = new List<Vial>();
    		temperature_history = new List<int>();
    		faulted = false;
    	}
    	
    	public Batch(int new_id, int temp)
    	{
    		id = new_id;
    		vials = new List<Vial>();
    		temperature_history = new List<int>();
    		temperature_history.Add(temp);
    		if (temp < 2 || temp > 8)
    		{
    			faulted = true;
    		}
    		else
    		{
    			faulted = false;
    		}
    	}
    	
    	// Required
    	public Batch(int new_id, List<Vial> new_vials, List<int> new_temperature_history, bool new_faulted)
    	{
    		id = new_id;
    		vials = new List<Vial>(new_vials);
    		temperature_history = new List<int>(new_temperature_history);
    		faulted = new_faulted;
    	}
    	
    	public bool addTempLog(int temp)
    	{
    		temperature_history.Add(temp);
    		if (temp < 2 || temp > 8)
    		{
    			faulted = true;
    			return true;
    		}
    		else return false;
    	}
    	
        // Required
        public override string ToString()
        {
            return "[Batch #" + id.ToString() + "]Containing " + vials.Count.ToString() +" vials. [Fault: " + faulted.ToString() + "]";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new Batch(id, vials, temperature_history, faulted);
        }

        // Required
        public override string ExpressionID
        {
            get {return "B"+id.ToString(); }
        }

    }
    
    public class BatchList : ExpressionValue
    {
    	public List<Batch> list;
    	
    	// Required
    	public BatchList()
    	{
    		list = new List<Batch>();
    	}
    	
    	// Required
    	public BatchList(List<Batch> new_batches)
    	{
    		list = new List<Batch>(new_batches);
    	}
    	
    	public int addBatch()
    	{
    		int new_batch_id = list.Count;
    		list.Add(new Batch(new_batch_id));
    		return new_batch_id;
    	}
    	
    	public int addBatchWithTemp(int temp)
    	{
    		int new_batch_id = list.Count;
    		list.Add(new Batch(new_batch_id, temp));
    		return new_batch_id;
    	}
    	
    	public int count()
    	{
    		return list.Count;
    	}
    	
    	public void setFaultByID(int id)
    	{
    		foreach (Batch b in list)
    		{
    			if (b.id == id)
    			{
    				b.faulted = true;
    			}
    		}
    	}
    	
    	public int getFaultyCount()
    	{
    		int faulty_count = 0;
    		foreach (Batch b in list)
    		{
    			if (b.faulted) faulty_count += 1;
    		}
    		return faulty_count;
    	}
    	
    	public bool checkFaulty(int batch_id)
    	{
    		if (list.Count <= batch_id) return false;
    		return list[batch_id].faulted;
    	}
    	
    	public int countBatchesWithPreviousInvalidTemperatures()
    	{
    		int count = 0;
    		bool current_batch_has_invalid;
    		foreach (Batch b in list)
    		{
    			current_batch_has_invalid = false;
    			foreach (int t in b.temperature_history)
    			{
    				if (t<2 || t>8)
    				{
    					current_batch_has_invalid = true;
    					break;
    				}
    			}
    			if (current_batch_has_invalid) count++;
    		}
    		return count;
    	}
    	
    	public bool addTempLogByID(int id, int temp)
    	{
    		foreach (Batch b in list) // Add requirement for no duplicate IDs
    		{
    			if (b.id == id)
    			{
    				return b.addTempLog(temp);
    			}
    		}
    		return false; // No matches
    	}
    	
    	public bool addRandomTempLog()
    	{
    		if (list.Count == 0) return false; // Can't choose a batch to update if there are no batches!
    		Random r = new Random();
    		int new_id = r.Next(0, list.Count);
    		int new_temp = r.Next(0,20);
    		return list[new_id].addTempLog(new_temp);
    	}
    	
        // Required
        public override string ToString()
        {
            return "Batch list containing " + list.Count.ToString() + " batches.";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new BatchList(list);
        }

        // Required
        public override string ExpressionID
        {
        get
        {
    		string exprID = "";
    		foreach (Batch b in list)
    		{
    			exprID += b.id.ToString() + ",";
    		}
    		return exprID;
        }
        }

    }
    
    public class Thermometer : ExpressionValue
    {
    	public int id;
    	public List<int> temperature_history;
		public int fridge_id;
    	
    	// Required
    	public Thermometer()
    	{
    		id = -1;
    		temperature_history = new List<int>();
			fridge_id = -1;
    	}
    	
    	// Required
    	public Thermometer(int new_id)
    	{
    		id = new_id;
    		temperature_history = new List<int>();
    		fridge_id = -1;
    	}
    	
    	// Required
    	public Thermometer(int new_id, List<int> new_temperature_history, int new_fridge_id)
    	{
    		id = new_id;
    		temperature_history = new List<int>(new_temperature_history);
			fridge_id = new_fridge_id;
    	}
    	
    	public int getTemperature()
    	{
    		return 4; // Determine under which conditions an invalid temperature should be returned
    	}
    	
        // Required
        public override string ToString()
        {
            return "[Thermometer #" + id.ToString() + "] in fridge " + fridge_id.ToString() +".";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new Thermometer(id, temperature_history, fridge_id);
        }

        // Required
        public override string ExpressionID
        {
            get {return "T"+id.ToString(); }
        }

    }
    
    public class Fridge : ExpressionValue
    {
    	public int id;
    	public List<Batch> batches;
    	public List<int> temperature_history;
    	public List<Thermometer> thermometers;
    	
    	// Required
    	public Fridge()
    	{
    		id = -1;
    		batches = new List<Batch>();
    		temperature_history = new List<int>();
    		thermometers = new List<Thermometer>();
    	}
    	
    	// Required
    	public Fridge(int new_id)
    	{
    		id = new_id;
    		batches = new List<Batch>();
    		temperature_history = new List<int>();
    		thermometers = new List<Thermometer>();
    	}
    	
    	// Required
    	public Fridge(int new_id, List<Batch> new_batches, List<int> new_temperature_history,
    				  List<Thermometer> new_thermometers)
    	{
    		id = new_id;
    		batches = new List<Batch>(new_batches);
    		temperature_history = new List<int>(new_temperature_history);
    		thermometers = new List<Thermometer>(new_thermometers);
    	}
    	
    	public int recordTemperature()
    	{
    		int total_temperature = 0;
    		int num_thermometers = thermometers.Count;
    		foreach (Thermometer t in thermometers)
    		{
    			total_temperature += t.getTemperature();
    		}
    		int average_temperature = total_temperature / num_thermometers;
    		temperature_history.Add(average_temperature);
    		if (average_temperature < 2 || average_temperature > 8)
    		{
    			foreach (Batch b in batches)
    			{
    				b.faulted = true;
    			}
    		}
    		return average_temperature;
    	}
    	
        // Required
        public override string ToString()
        {
            return "[Fridge #" + id.ToString() + "]Containing " + batches.Count.ToString() +" batches.";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new Fridge(id, batches, temperature_history, thermometers);
        }

        // Required
        public override string ExpressionID
        {
            get {return "F"+id.ToString(); }
        }

    }
    
    public class FridgeList : ExpressionValue
    {
    	public List<Fridge> list;
    	
    	// Required
    	public FridgeList()
    	{
    		list = new List<Fridge>();
    	}
    	
    	// Required
    	public FridgeList(List<Fridge> new_list)
    	{
    		list = new List<Fridge>(new_list);
    	}
    	
        // Required
        public override string ToString()
        {
            return "[Fridge list containing " + list.Count.ToString() +" fridges.";
        }

        // Required
        public override ExpressionValue GetClone()
        {
            return new FridgeList(list);
        }

        // Required
        public override string ExpressionID
        {
            get {return "FL"+list.Count.ToString(); }
        }

    }
}
