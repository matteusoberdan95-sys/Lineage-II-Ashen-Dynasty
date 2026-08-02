/*
 * Ashen Dynasty — Sprint 16
 * Transition quest TT -> Draconic (token/recipe reward, not a full set).
 */
package quests.Q00900_AshenScaleOfTransition;

import org.l2jmobius.gameserver.model.actor.Npc;
import org.l2jmobius.gameserver.model.actor.Player;
import org.l2jmobius.gameserver.model.script.Quest;
import org.l2jmobius.gameserver.model.script.QuestState;
import org.l2jmobius.gameserver.model.script.State;

/**
 * One-time bridge after Ashen TT farming: exchange TT fragments for Draconic
 * fragments + one key craft recipe (ADR-007 / ADR-008).
 */
public class Q00900_AshenScaleOfTransition extends Quest
{
	private static final int CHRONICLER = 93002;
	private static final int TT_FRAGMENT = 9399;
	private static final int DRACONIC_FRAGMENT = 9499;
	private static final int RECIPE_DRACONIC_BREASTPLATE = 9524;
	private static final int REQUIRED_TT_FRAGMENTS = 15;
	private static final int REWARD_DRACONIC_FRAGMENTS = 12;
	private static final int MIN_LEVEL = 76;
	
	public Q00900_AshenScaleOfTransition()
	{
		super(900, "Ashen Scale of Transition");
		setCustom(true);
		addStartNpc(CHRONICLER);
		addTalkId(CHRONICLER);
	}
	
	@Override
	public String onEvent(String event, Npc npc, Player player)
	{
		final QuestState st = getQuestState(player, false);
		if (st == null)
		{
			return null;
		}
		
		switch (event)
		{
			case "93002-02.htm":
			{
				st.startQuest();
				break;
			}
			case "93002-05.htm":
			{
				if (!st.isCond(1))
				{
					return event;
				}
				if (getQuestItemsCount(player, TT_FRAGMENT) < REQUIRED_TT_FRAGMENTS)
				{
					return "93002-03.htm";
				}
				
				takeItems(player, TT_FRAGMENT, REQUIRED_TT_FRAGMENTS);
				giveItems(player, DRACONIC_FRAGMENT, REWARD_DRACONIC_FRAGMENTS);
				giveItems(player, RECIPE_DRACONIC_BREASTPLATE, 1);
				st.exitQuest(false, true);
				break;
			}
		}
		
		return event;
	}
	
	@Override
	public String onTalk(Npc npc, Player player)
	{
		final QuestState st = getQuestState(player, true);
		String htmltext = getNoQuestMsg(player);
		
		switch (st.getState())
		{
			case State.CREATED:
			{
				htmltext = (player.getLevel() < MIN_LEVEL) ? "93002-00.htm" : "93002-01.htm";
				break;
			}
			case State.STARTED:
			{
				htmltext = (getQuestItemsCount(player, TT_FRAGMENT) < REQUIRED_TT_FRAGMENTS) ? "93002-03.htm" : "93002-04.htm";
				break;
			}
			case State.COMPLETED:
			{
				htmltext = getAlreadyCompletedMsg(player);
				break;
			}
		}
		
		return htmltext;
	}
	
	public static void main(String[] args)
	{
		new Q00900_AshenScaleOfTransition();
	}
}
