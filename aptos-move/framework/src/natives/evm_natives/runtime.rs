
pub struct Runtime {
    checkpoints: Vec<RunState>
}

impl Runtime {
    pub fn new() -> Self {
        Self {
            checkpoints: Vec::new(),
        }
    }

    pub fn new_checkpoint(&mut self, gas_limit: u64, is_static: bool) {
        if self.checkpoints.len() > 0 {
            let last_state = self.checkpoints.last().unwrap();
            let is_static = last_state.is_static || is_static;
            let gas_refund = last_state.gas_refund;
            self.checkpoints.push(RunState::new(gas_limit, is_static, gas_refund));
        } else {
            self.checkpoints.push(RunState::new(gas_limit, is_static, 0));
        }
        
    }

    pub fn revert_checkpoint(&mut self) {
        let new_state = self.checkpoints.pop().unwrap();
        let old_state = self.checkpoints.last_mut().unwrap();
        old_state.gas_left = if old_state.gas_left > new_state.gas_limit {
            old_state.gas_left - new_state.gas_limit 
        } else {
            0 
        };
    }

    pub fn commit_checkpoint(&mut self) {
        let new_state = self.checkpoints.pop().unwrap();
        let old_state = self.checkpoints.last_mut().unwrap();
        old_state.gas_refund = new_state.gas_refund;
        old_state.gas_left -= new_state.gas_limit - new_state.gas_left;
    }

    pub fn add_gas_usage(&mut self, gas_used: u64) -> bool {
        let current_state = self.checkpoints.last_mut().unwrap();
        if current_state.gas_left >= gas_used {
            current_state.gas_left -= gas_used;
            true
        } else {
            current_state.gas_left = 0;
            false
        }
    }
    

    pub fn add_gas_left(&mut self, gas: u64) {
        let current_state = self.checkpoints.last_mut().unwrap();
        current_state.gas_left += gas;
    }

    pub fn add_gas_refund(&mut self, gas: u64) {
        let current_state = self.checkpoints.last_mut().unwrap();
        current_state.gas_refund += gas;
    }

    pub fn sub_gas_refund(&mut self, gas: u64) {
        let current_state = self.checkpoints.last_mut().unwrap();
        if current_state.gas_refund >= gas {
            current_state.gas_refund -= gas;
        } else {
            current_state.gas_refund = 0;
        }
    }

    pub fn get_gas_refund(&self) -> u64 {
        self.checkpoints.last().unwrap().gas_refund
    }

    pub fn clear_gas_refund(&mut self) {
        let current_state = self.checkpoints.last_mut().unwrap();
        current_state.gas_refund = 0;
    }

    pub fn get_is_static(&self) -> bool {
        self.checkpoints.last().unwrap().is_static
    }

    pub fn get_gas_left(&self) -> u64 {
        self.checkpoints.last().unwrap().gas_left
    }

     
}

pub struct RunState {
    gas_refund: u64,
    gas_left: u64,
    gas_limit: u64,
    is_static: bool
}


impl RunState {
    pub fn new(gas_limit: u64, is_static: bool, gas_refund: u64) -> Self {
        Self {
            gas_refund,
            gas_left: gas_limit,
            gas_limit,
            is_static,
        }
    }

    
}