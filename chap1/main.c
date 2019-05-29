/*
Author:         ZhangYin, zhangyin2018@iscas.ac.cn
Version:        1.0.1
Date:           May 17, 2019
Description:    Tiger compiler chap1, interpretor of straight-line program language
				There are some robustness problems in this version's implementation, 
				which still need to be improved.
 */

#include <stdio.h>
#include "util.h"
#include "slp.h"
#include "prog1.h"

int maxargs(A_stm s){

	switch(s->kind){

		case A_compoundStm:{
			int leftMax = maxargs(s->u.compound.stm1);
			int rightMax = maxargs(s->u.compound.stm2);
			return (leftMax > rightMax)? leftMax : rightMax;
		}

		case A_assignStm:{
			A_exp e = s->u.assign.exp;
			if (e->kind == A_eseqExp)
				return maxargs(e->u.eseq.stm);
			else
				return 0;
		}

		case A_printStm:{
			int max = 0;
			int count = 1;
			A_expList list = s->u.print.exps;
			while(list->kind != A_lastExpList){
				A_exp e = list->u.pair.head;
				if (e->kind == A_eseqExp){
					int temp = maxargs(e->u.eseq.stm);
					max = (max > temp)? max : temp;
				}
				list = list->u.pair.tail;
				count += 1;
			}
			A_exp e = list->u.last;
			if (e->kind == A_eseqExp){
				int temp = maxargs(e->u.eseq.stm);
				max = (max > temp)? max : temp;
			}
			return (max > count)? max : count;
		}

		default:
			return 0;

	}

}

typedef struct table *Table_;
struct table{
	string id;
	int value;
	Table_ tail;
};
Table_ Table(string id, int value, struct table *tail){
	Table_ t = checked_malloc(sizeof(*t));
	t->id = id;
	t->value = value;
	t->tail = tail;
	return t;
}

typedef struct IntAndTable *iTable_;
struct IntAndTable{
	int value;
	Table_ t;
};
iTable_ iTable(int value, Table_ t){
	iTable_ it = checked_malloc(sizeof(*it));
	it->value = value;
	it->t = t;
	return it;
}

Table_ update(Table_ t, string id, int value){
	return Table(id, value, t);
}

int lookup(Table_ t, string key){
	while (t != NULL) {
		if(t->id == key)
			return t->value;
		t = t->tail;
	}
	return -1;
}

Table_ interpStm(A_stm, Table_);
iTable_ interpExp(A_exp, Table_);
Table_ interpExpList(A_expList, Table_, int);


Table_ interpStm(A_stm s, Table_ t){

	switch(s->kind){

		case A_compoundStm:{
			t = interpStm(s->u.compound.stm1, t);
			t = interpStm(s->u.compound.stm2, t);
			return t;
		}

		case A_assignStm:{
			iTable_ it = interpExp(s->u.assign.exp, t);
			t = update(it->t, s->u.assign.id, it->value);
			return t;
		}

		case A_printStm:
			return interpExpList(s->u.print.exps, t, 1);
		
		default:
			return t;

	}

}

iTable_ interpExp(A_exp e, Table_ t){

	switch(e->kind){

		case A_idExp:
			return iTable(lookup(t, e->u.id), t);

		case A_numExp:
			return iTable(e->u.num, t);

		case A_opExp:{
			iTable_ left = interpExp(e->u.op.left, t);
			iTable_ right = interpExp(e->u.op.right, t);
			switch(e->u.op.oper){
				case A_plus:
					return iTable(left->value + right->value, t);
				case A_minus:
					return iTable(left->value - right->value, t);
				case A_times:
					return iTable(left->value * right->value, t);
				case A_div:
					return iTable(left->value / right->value, t);	
				default:
					return NULL;
			}
		}

		case A_eseqExp:{
			t = interpStm(e->u.eseq.stm, t);
			iTable_ it = interpExp(e->u.eseq.exp, t);
			return it;
		}

		default:
			return NULL;

	}

}

Table_ interpExpList(A_expList e, Table_ t, int printFlag){

	switch(e->kind){

		case A_pairExpList:{
			iTable_ it = interpExp(e->u.pair.head, t);
			if(printFlag)
				printf("%d ", it->value);
			t = interpExpList(e->u.pair.tail, it->t, printFlag);
			return t;
		}

		case A_lastExpList:{
			iTable_ it = interpExp(e->u.last, t);
			if(printFlag)
				printf("%d\n", it->value);
			return it->t;
		}

		default:
			return t;

	}

}

void interp(A_stm s){

	interpStm(s, NULL);

}

int main(){

	A_stm stm = prog();
	
	printf("the maximum number of arguments of any print statement is %d\n", maxargs(stm));
	
	interp(stm);

	return 0;
	
}