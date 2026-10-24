module alcancia::alcancia {
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;

    // Códigos de error
    const ENoEresDueno: u64 = 0;
    const EMetaNoAlcanzada: u64 = 1;

    // La alcancía: quién es el dueño, cuánto quiere ahorrar y cuánto lleva
    public struct Alcancia has key {
        id: UID,
        dueno: address,
        meta: u64,          // en MIST (1 SUI = 1_000_000_000 MIST)
        ahorro: Balance<SUI>,
    }

    // Crea una alcancía con una meta de ahorro
    public fun crear(meta: u64, ctx: &mut TxContext) {
        let a = Alcancia {
            id: object::new(ctx),
            dueno: ctx.sender(),
            meta,
            ahorro: balance::zero(),
        };
        transfer::share_object(a);
    }

    // Cualquiera puede meter plata (tú, un familiar, un amigo...)
    public fun depositar(a: &mut Alcancia, pago: Coin<SUI>) {
        balance::join(&mut a.ahorro, coin::into_balance(pago));
    }

    // Solo el dueño puede sacar, y solo si ya llegó a la meta
    public fun retirar(a: &mut Alcancia, ctx: &mut TxContext) {
        assert!(ctx.sender() == a.dueno, ENoEresDueno);
        let total = balance::value(&a.ahorro);
        assert!(total >= a.meta, EMetaNoAlcanzada);
        let plata = coin::take(&mut a.ahorro, total, ctx);
        transfer::public_transfer(plata, a.dueno);
    }

    // Ver cuánto llevas ahorrado
    public fun saldo(a: &Alcancia): u64 {
        balance::value(&a.ahorro)
    }
}
