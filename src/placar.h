#ifndef PLACAR_H
#define PLACAR_H


struct t_placar {
    void (*goal)(int player);
    void (*inc)(int player);
    void (*draw)();
    void (*setup)();
};


extern const struct t_placar Placar;

#endif
