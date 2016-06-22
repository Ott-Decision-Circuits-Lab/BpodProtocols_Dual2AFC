function sma = stateMatrix(TaskParameters,iTrial)
global BpodSystem
ValveTimes  = GetValveTimes(TaskParameters.GUI.RewardAmount, [1 3]);
LeftValveTime = ValveTimes(1);
RightValveTime = ValveTimes(2);
clear ValveTimes

if BpodSystem.Data.Custom.OdorID(iTrial) == 1
    LeftPokeAction = 'rewarded_Lin';
    RightPokeAction = 'unrewarded_Rin';
elseif BpodSystem.Data.Custom.OdorID(iTrial) == 2
    LeftPokeAction = 'unrewarded_Lin';
    RightPokeAction = 'rewarded_Rin';
else
    error('Bpod:Olf2AFC:unknownOdorID','Undefined Odor ID')
end

sma = NewStateMatrix();
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {'Port2In', 'stay_Cin'},...
    'OutputActions', {'SoftCode',2,'PWM2',255});
sma = AddState(sma, 'Name', 'stay_Cin',...
    'Timer', BpodSystem.Data.Custom.StimDelay(end),...
    'StateChangeConditions', {'Port2Out','broke_fixation','Tup', 'odor_delivery'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'broke_fixation',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{});
% sma = AddState(sma, 'Name', 'pre_odor_delivery',...
%     'Timer', 0.1,... % Time for odor to reach nostrils (Junya filtered these trials out offline)
%     'StateChangeConditions', {'Port2Out','ITI','Tup','odor_delivery'},...
%     'OutputActions', {'SoftCode',BpodSystem.Data.Custom.OdorPair(iTrial)});
sma = AddState(sma, 'Name', 'odor_delivery',...
    'Timer', 0,...
    'StateChangeConditions', {'Port2Out','wait_Sin'},...
    'OutputActions', {'SoftCode',BpodSystem.Data.Custom.OdorPair(iTrial)});
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer',0,...
    'StateChangeConditions', {'Port1In',LeftPokeAction,'Port3In',RightPokeAction},...
    'OutputActions',{'SoftCode',2,'PWM1',255,'PWM3',255});
sma = AddState(sma, 'Name', 'rewarded_Lin',...
    'Timer', TaskParameters.GUI.FeedbackDelay,...
    'StateChangeConditions', {'Port1Out','skipped_feedback','Tup','water_L'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'rewarded_Rin',...
    'Timer', TaskParameters.GUI.FeedbackDelay,...
    'StateChangeConditions', {'Port3Out','skipped_feedback','Tup','water_R'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'unrewarded_Lin',...
    'Timer', TaskParameters.GUI.FeedbackDelay,...
    'StateChangeConditions', {'Port1Out','skipped_feedback','Tup','time_out'},...
    'OutputActions', {}); % SHOULD WRITE WAVEFORM TO PULSEPAL WITHIN THIS CODE
sma = AddState(sma, 'Name', 'unrewarded_Rin',...
    'Timer', TaskParameters.GUI.FeedbackDelay,...
    'StateChangeConditions', {'Port3Out','skipped_feedback','Tup','time_out'},...
    'OutputActions', {});% RATHER THAN PLAYING WHATEVER IS THERE
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', 1});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', 4});
sma = AddState(sma, 'Name', 'time_out',...
    'Timer',TaskParameters.GUI.TimeOut,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'BNCState',1});
sma = AddState(sma, 'Name', 'skipped_feedback',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'ITI',...
    'Timer',TaskParameters.GUI.ITI,...
    'StateChangeConditions',{'Tup','exit'},...
    'OutputActions',{'SoftCode',32}); % Sets flow rates for next trial
% sma = AddState(sma, 'Name', 'state_name',...
%     'Timer', 0,...
%     'StateChangeConditions', {},...
%     'OutputActions', {});
end