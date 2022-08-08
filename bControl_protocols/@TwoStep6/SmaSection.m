
function  [] =  SmaSection(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        %% next_trial
    case 'next_trial',
        
        
        
       % inlines = struct('C',1+inputlines_offset,'L',2+inputlines_offset,'R',3+inputlines_offset,'c',4+inputlines_offset,'l',5+inputlines_offset,'r',6+inputlines_offset);
        line_names = 'CLRclr';
        sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        
        left2led           = bSettings('get', 'DIOLINES', 'left2led');
        center2led         = bSettings('get', 'DIOLINES', 'center2led');
        right2led          = bSettings('get', 'DIOLINES', 'right2led');
        
        % Find out which training stage we're in - this will tell us where
        % in the state machine we should be starting
        training_stage = TrainingSection(obj,'get_training_stage');
       
        % Get the timing information
        timing = TimingSection(obj,'get_timing');
        params = ParamsSection(obj,'get_params');
        
        
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        LeftWValveTime_small = LeftWValveTime*timing.unreward_mult; RightWValveTime_small = RightWValveTime*timing.unreward_mult;
        
        switch training_stage
            case 'full_task'
                begin_state = 'stepone_state';
            case 'one_step'
                if rand < 0.5
                    begin_state = 'left_state';
                else
                    begin_state = 'right_state';
                end
            case 'side_poke'
                if rand < params.p_right
                    begin_state = 'choice_state_2r';
                else
                    begin_state = 'choice_state_2l';
                end
            case 'direct_delivery'
                if rand < 0.5
                    begin_state = 'left_reward_state';
                else
                    begin_state = 'right_reward_state';
                end
            otherwise
                error('Undefined training stage');
        end


        
        % parse behavior we want for the center led 
        switch value(timing.center_led),
            case 'off',
                pre_cpoke_led1 = 0;
                cpoke_led1= 0;
                cbreak_led1 = 0;
                pre_cpoke_led2 = 0;
                cpoke_led2= 0;
                cbreak_led2 = 0;
            case 'on',
                pre_cpoke_led1 = center2led;
                cpoke_led1= center2led;
                cbreak_led1 = center2led;
                
                pre_cpoke_led2 = center1led;
                cpoke_led2 = center1led;
                cbreak_led2 = center1led;
                
            case 'off_at_cpoke',
                pre_cpoke_led1 = center2led;
                cpoke_led1 = 0;
                cbreak_led1 = center2led;
                
                pre_cpoke_led2 = center1led;
                cpoke_led2 = 0;
                cbreak_led2 = center1led;
                
            case 'on_at_cpoke',
                pre_cpoke_led1 = 0;
                cpoke_led1 = center2led;
                cbreak_led1 = 0;
                
                pre_cpoke_led2 = 0;
                cpoke_led2 = center1led;
                cbreak_led2 = 0;
        end
        
        % Parse subsequent states for each poke
        if rand < params.p_congruent % congruent
            left_sub_state = 'left_state';
            right_sub_state = 'right_state';
        else % incongruent
            left_sub_state = 'right_state';
            right_sub_state = 'left_state';
        end
        
        % Parse force-left & force-right
        % Make sure that the appropriate lights go on, and that the rat
        % gets sent straight to violation if he violates
        % The indicator states are throwaway states that get tagged on
        % after WD so we can later parse the trial type
        r = rand;
        if r < params.p_forceRight
            first_choice_lights = right2led;
            left_sub_state = 'violation_penalty1';
            indicator_state  = 'force_right';
        elseif r > 1 - params.p_forceLeft;
            first_choice_lights = left2led;
            right_sub_state = 'violation_penalty1';
            indicator_state  = 'force_left';
        else
            first_choice_lights = left2led + right2led;
            indicator_state  = 'free_choice';
        end
        
        % Parse behavior we want for the sounds
        left_sound_id = SoundManagerSection(obj, 'get_sound_id', 'left_sound');
        right_sound_id = SoundManagerSection(obj, 'get_sound_id', 'right_sound');
        silence_id = SoundManagerSection(obj, 'get_sound_id', 'silence');
        switch timing.sound_timing
            case 'No Sound'
                left_state_sound = silence_id;
                right_state_sound = silence_id;
                left_cpoke_sound = silence_id;
                right_cpoke_sound = silence_id;
            case 'After Cpoke'
                left_state_sound = silence_id;
                right_state_sound = silence_id;
                left_cpoke_sound = left_sound_id;
                right_cpoke_sound = right_sound_id;
            case 'After 1st Sidepoke'
                left_state_sound = left_sound_id;
                right_state_sound = right_sound_id;
                left_cpoke_sound = left_sound_id;
                right_cpoke_sound = right_sound_id;
        end
        
        % Parse behavior we want for the lights
        switch timing.side_light_timing
            case 'Both On'
                left_choice_lights = left1led+right1led;
                right_choice_lights = left1led+right1led;
            case 'Both Off'
                left_choice_lights = 0;
                right_choice_lights = 0;
            case 'Instructed'
                left_choice_lights = left1led;
                right_choice_lights = right1led;
        end
        
        % Parse behavior we want after the second poke
         if timing.unreward_punish
            post_unreward_state = 'unreward_penalty';
        else
            post_unreward_state = 'cleanup_state';
         end
        
         
               
        if rand < params.left_reward_prob
            post_correct_left = 'left_reward_state';
        else
            if timing.unreward_water
                post_correct_left = 'left_small_reward_state';
            else
                post_correct_left = 'left_unreward_state';
            end
        end
        if rand < params.right_reward_prob
            post_correct_right = 'right_reward_state';
        else
            if timing.unreward_water
                post_correct_right = 'right_small_reward_state';
            else
                post_correct_right = 'right_unreward_state';
            end
        end
        %% State machine for direct delivery
        
        
        %% State machine for the first center poke
        sma = add_state(sma,'name','trial_ready','self_timer',min_time,'input_to_statechange',{'Tup',begin_state});
        
        sma = add_state(sma,'name','stepone_state','output_actions',{'DOut',pre_cpoke_led1},'input_to_statechange',{'chi','nose_in_center_1'});
        
        % Nic_timer_1 starts at the first center poke, and he's dropped
        % into nose_in_center_1
        % if he leaves the center port befor the timer is up, he goes first
        % to legal_cbreak_1
        % If he returns to center before the self_timer of legal_cbreak_1
        % is up, he gets put back into nose_in_center_1, and everything's
        % fine
        % If he stays out too long, he gets put into cpoke_violation
        % If he's still out of the center port when the timer goes up, he
        % needs to tag the center port again in order to move on - this
        % happens with wait_for_cbreak_over_1
        % If at any time he pokes a side poke, he gets put into
        % early_sidepokes_penalty
        sma = add_scheduled_wave(sma, 'name', 'nic_timer_1',  'preamble', timing.nose_in_center);
        sma = add_state(sma,'name','nose_in_center_1',...
            'output_actions',{'DOut',cpoke_led1,'SchedWaveTrig','nic_timer_1'},...
            'input_to_statechange',{'clo','legal_cbreak_1','nic_timer_1_In','choice_state_1','lhi','early_sidepokes_penalty_1','rhi','early_sidepokes_penalty_1'});
        sma = add_state(sma,'name','legal_cbreak_1',...
            'self_timer',timing.legal_cbreak,...
            'output_actions',{'DOut',cbreak_led1},...
            'input_to_statechange',{'chi','nose_in_center_1','nic_timer_1_In','cpoke_violation_1','Tup','cpoke_violation_1','lhi','early_sidepokes_penalty_1','rhi','early_sidepokes_penalty_1'});
        
        % Penalty states
        sma = add_state(sma, 'name','cpoke_violation_1','self_timer',timing.cpoke_violation_timeout,...
            'output_actions',{'SchedWaveTrig','-nic_timer_1'},'input_to_statechange',{'Tup','trial_ready'});
        sma = PunishInterface(obj, 'add_sma_states', 'early_sidepokes_penalty_1', sma, 'exitstate', 'trial_ready');
        
        %% State machine for the first choice
        sma = add_state(sma,'name','choice_state_1',...
            'output_actions',{'DOut',first_choice_lights},...
            'input_to_statechange',{'lhi','left_choice_1','rhi','right_choice_1'});
        sma = add_state(sma,'name','left_choice_1',...
            'self_timer',min_time, 'input_to_statechange',{'Tup',left_sub_state});
        sma = add_state(sma,'name','right_choice_1',...
            'self_timer',min_time, 'input_to_statechange',{'Tup',right_sub_state});
        
        sma = add_state(sma,'name','left_state',...
            'output_actions',{'SoundOut', left_state_sound,'DOut',pre_cpoke_led2},...
            'input_to_statechange',{'Chi','nose_in_center_2l','Lhi','early_sidepokes_penalty_2l','Rhi','early_sidepokes_penalty_2l'});
       
        sma = add_state(sma,'name','right_state',...
            'output_actions',{'SoundOut', right_state_sound,'DOut',pre_cpoke_led2},...
            'input_to_statechange',{'Chi','nose_in_center_2r','Lhi','early_sidepokes_penalty_2r','Rhi','early_sidepokes_penalty_2r'});
        
        %% State machine for second NIC - one set of states for each subsequent side
        sma = add_scheduled_wave(sma, 'name', 'nic_timer_2l',  'preamble', timing.nose_in_center);
        sma = add_scheduled_wave(sma, 'name', 'nic_timer_2r',  'preamble', timing.nose_in_center);
        
        sma = add_state(sma,'name','nose_in_center_2l',...
            'output_actions',{'DOut',cpoke_led2,'SchedWaveTrig','nic_timer_2l','SoundOut', left_cpoke_sound},...
            'input_to_statechange',{'Clo','legal_cbreak_2l','nic_timer_2l_In','choice_state_2l','Lhi','early_sidepokes_penalty_2l','Rhi','early_sidepokes_penalty_2l'});
        sma = add_state(sma,'name','nose_in_center_2r',...
            'output_actions',{'DOut',cpoke_led2,'SchedWaveTrig','nic_timer_2r','SoundOut', right_cpoke_sound},...
            'input_to_statechange',{'Clo','legal_cbreak_2r','nic_timer_2r_In','choice_state_2r','Lhi','early_sidepokes_penalty_2r','Rhi','early_sidepokes_penalty_2r'});
        
        sma = add_state(sma,'name','legal_cbreak_2l',...
            'self_timer',timing.legal_cbreak,...
            'output_actions',{'DOut',cbreak_led2},...
            'input_to_statechange',{'Chi','nose_in_center_2l','nic_timer_2l_In','cpoke_violation_2l','Tup','cpoke_violation_2l','Lhi','early_sidepokes_penalty_2l','Rhi','early_sidepokes_penalty_2l'});
        sma = add_state(sma,'name','legal_cbreak_2r',...
            'self_timer',timing.legal_cbreak,...
            'output_actions',{'DOut',cbreak_led2},...
            'input_to_statechange',{'Chi','nose_in_center_2r','nic_timer_2r_In','cpoke_violation_2r','Tup','cpoke_violation_2r','Lhi','early_sidepokes_penalty_2r','Rhi','early_sidepokes_penalty_2r'});  
        
        sma = add_state(sma, 'name','cpoke_violation_2l','self_timer',timing.cpoke_violation_timeout,...
            'output_actions',{'SchedWaveTrig','-nic_timer_2l'},'input_to_statechange',{'Tup','left_state'});
        sma = add_state(sma, 'name','cpoke_violation_2r','self_timer',timing.cpoke_violation_timeout,...
            'output_actions',{'SchedWaveTrig','-nic_timer_2r'},'input_to_statechange',{'Tup','right_state'});
        
        sma = PunishInterface(obj, 'add_sma_states', 'early_sidepokes_penalty_2l', sma, 'exitstate', 'left_state');
        sma = PunishInterface(obj, 'add_sma_states', 'early_sidepokes_penalty_2r', sma, 'exitstate', 'right_state');
        
        %% Second-step choice states
        sma = add_state(sma,'name','choice_state_2l',...
            'output_actions',{'DOut',left_choice_lights},...
            'input_to_statechange',{'Lhi',post_correct_left,'Rhi','violation_penalty2'});
        sma = add_state(sma,'name','choice_state_2r',...
            'output_actions',{'DOut',right_choice_lights},...
            'input_to_statechange',{'Rhi',post_correct_right,'Lhi','violation_penalty2'});
        
        %% Reward, unreward, and violation states
        if timing.softdrink_enabled
            left_noseout_state = 'left_softdrink_out_state';
            right_noseout_state = 'right_softdrink_out_state';
        else
            left_noseout_state = 'left_reward_state';
            right_noseout_state = 'right_reward_state';
        end
        
           
        
        sma = add_scheduled_wave(sma,'name','left_reward_wav','preamble',timing.reward_delay,'sustain',LeftWValveTime,'DOut',left1water,'refraction',timing.drink_time);
        sma = add_scheduled_wave(sma,'name','right_reward_wav','preamble',timing.reward_delay,'sustain',RightWValveTime,'DOut',right1water,'refraction',timing.drink_time);
        sma = add_scheduled_wave(sma,'name','left_small_reward_wav','preamble',timing.reward_delay,'sustain',LeftWValveTime_small,'DOut',left1water,'refraction',timing.drink_time);
        sma = add_scheduled_wave(sma,'name','right_small_reward_wav','preamble',timing.reward_delay,'sustain',RightWValveTime_small,'DOut',right1water,'refraction',timing.drink_time);

        sma = add_scheduled_wave(sma,'name','drink_timer','preamble',timing.drink_time);
        
         % Reward states, including soft-drink
        sma = add_state(sma,'name','left_reward_state','output_actions',{'SchedWaveTrig','left_reward_wav+drink_timer'},'input_to_statechange',{'Llo',left_noseout_state,'drink_timer_In','cleanup_state'});
        sma = add_state(sma,'name','right_reward_state','output_actions',{'SchedWaveTrig','right_reward_wav+drink_timer'},'input_to_statechange',{'Rlo',right_noseout_state,'drink_timer_In','cleanup_state'});
        
        sma = add_state(sma,'name','left_softdrink_out_state','self_timer',timing.softdrink_time,'input_to_statechange',{'Tup','cleanup_state','Lhi','left_softdrink_in_state','drink_timer_In','cleanup_state'});
        sma = add_state(sma,'name','right_softdrink_out_state','self_timer',timing.softdrink_time,'input_to_statechange',{'Tup','cleanup_state','Rhi','right_softdrink_in_state','drink_timer_In','cleanup_state'});
        sma = add_state(sma,'name','left_softdrink_in_state','input_to_statechange',{'drink_timer_In','cleanup_state','Llo','left_softdrink_out_state'});
        sma = add_state(sma,'name','right_softdrink_in_state','input_to_statechange',{'drink_timer_In','cleanup_state','Rlo','right_softdrink_out_state'});
        
        % Unrewarded states
        sma = add_state(sma,'name','left_unreward_state','self_timer',timing.unreward_time,'input_to_statechange',{'Tup',post_unreward_state});
        sma = add_state(sma,'name','right_unreward_state','self_timer',timing.unreward_time,'input_to_statechange',{'Tup',post_unreward_state});
        sma = PunishInterface(obj,'add_sma_states','unreward_penalty',sma,'exitstate','cleanup_state');
        
        % Small reward states
        sma = add_state(sma,'name','left_small_reward_state','output_actions',{'SchedWaveTrig','left_small_reward_wav+drink_timer'},'input_to_statechange',{'Llo',left_noseout_state,'drink_timer_In','cleanup_state'});
        sma = add_state(sma,'name','right_small_reward_state','output_actions',{'SchedWaveTrig','right_small_reward_wav+drink_timer'},'input_to_statechange',{'Rlo',right_noseout_state,'drink_timer_In','cleanup_state'});

        % Violation states
        sma = PunishInterface(obj, 'add_sma_states', 'violation_penalty1', sma, 'exitstate', 'cleanup_state');
        sma = PunishInterface(obj, 'add_sma_states', 'violation_penalty2', sma, 'exitstate', 'cleanup_state');
        
        %% Cleanup states
        sma = add_state(sma, 'name', 'cleanup_state', 'self_timer', min_time, ...
            'output_actions', {'SoundOut', -left_sound_id},...
            'input_to_statechange', {'Tup', 'cleanup_state2'});
        sma = add_state(sma, 'name', 'cleanup_state2', 'self_timer', min_time, ...
            'output_actions', {'SoundOut', -right_sound_id},...
            'input_to_statechange', {'Tup', 'wd'});
        
        sma = WarnDangerInterface(obj,'add_sma_states','wd',sma,'exitstate',indicator_state,'on_poke_when_danger_state','dangerpokes_penalty');
        sma = PunishInterface(obj, 'add_sma_states', 'dangerpokes_penalty', sma, 'exitstate', 'wd');
        
        %% States thrown in to indicate what the trial_type was
        sma = add_state(sma,'name','free_choice','self_timer',min_time,'input_to_statechange',{'Tup','check_next_trial_ready'});
        sma = add_state(sma,'name','force_left','self_timer',min_time,'input_to_statechange',{'Tup','check_next_trial_ready'});
        sma = add_state(sma,'name','force_right','self_timer',min_time,'input_to_statechange',{'Tup','check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, {'check_next_trial_ready','trial_ready'});
        
        %% reinit
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


end