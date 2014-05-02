#include "bcalcdds.h"
#include <stdio.h>
//check if solver is in error state, and if it is, print error message
void print_on_error(BCalcDDS* solver) {
	const char* err = bcalcDDS_getLastError(solver);
	if (err) printf("ERROR %s\n", err);
}

//print which player play now and how many tricks he can take
void print_tricks(BCalcDDS* solver) {
	printf("%c playes, and he with partner will be able to take %d tricks.\n",
	 bcalc_playerSymbol(bcalcDDS_getPlayerToPlay(solver)),
	 bcalcDDS_getTricksToTake(solver)
	);
	print_on_error(solver);
}

//play all card in given suit and call print_tricks for situation after each play
void play(BCalcDDS* solver, int suit) {
	char to_play[14];
	bcalcDDS_getCardsToPlay(solver, to_play, suit);
	printf("Cards possible to play in suit %c: %s\n", bcalc_suitSymbol(suit), to_play);
	char play_cmd[3];   //string chars: card symbol, suit symbol, string termination zero
	play_cmd[1] = bcalc_suitSymbol(suit);
	play_cmd[2] = 0;
	int i;
	for (i = 0; to_play[i] != 0; ++i) {
		play_cmd[0] = to_play[i];
		printf(" After play %s: ", play_cmd);
		bcalcDDS_exec(solver, play_cmd);
		print_tricks(solver);
		bcalcDDS_exec(solver, "u");	//undo
	}
}

//call play for all suits
void play_all_suits(BCalcDDS* solver) {
	print_tricks(solver);
	int suit;
	for (suit = 0; suit < 4; ++suit)
		play(solver, suit);
}

//print number of tricks possible to take and all best moves
void find_best_moves(BCalcDDS* solver) {
	int target = bcalcDDS_getTricksToTake(solver);
	printf("%c playes, and he with partner will be able to take %d tricks by play:",
	 bcalc_playerSymbol(bcalcDDS_getPlayerToPlay(solver)), target
	);
	int suit;
	char card_to_play[3];	//<rank><suit><null>
	card_to_play[2] = 0;
	for (suit = 0; suit < 4; ++suit) {
		card_to_play[1] = bcalc_suitSymbol(suit);
		char all_cards_to_play[14];
		bcalcDDS_getCardsToPlay(solver, all_cards_to_play, suit);
		int i;
		for (i = 0; all_cards_to_play[i] != 0; ++i) {
			card_to_play[0] = all_cards_to_play[i];
			if (bcalcDDS_getTricksToTakeEx(solver, target, card_to_play))
				printf(" %s", card_to_play);
		}
	}
	printf("\n");
}

int main() {
	BCalcDDS* solver = bcalcDDS_new("PBN", "N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85", BCALC_NT, BCALC_PLAYER_NORTH);
	if (!solver) {
		printf("Can't create solver!");
		return 1;
	}
	print_on_error(solver);

	play_all_suits(solver);
	find_best_moves(solver);

	char* to_play = "7D x x";
	printf("\nPlay some cards: %s\n", to_play);
	bcalcDDS_exec(solver, to_play);
	print_on_error(solver);
	play_all_suits(solver);
	find_best_moves(solver);

	bcalcDDS_delete(solver);

	return 0;
}
